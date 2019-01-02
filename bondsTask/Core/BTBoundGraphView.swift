//
//  BTBoundGraphView.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import UIKit
import SwiftCharts
import DateToolsSwift

enum BTBoundDataType: String {
    case Yield = "yield"
    case Price = "price"
}

enum BTBoundDataProviderType: Int{
    case local
    case http
    case webSoket
}

class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

class BTBoundGraphView: UIView {
    
    var viewDatePeriod: (from: Date, to: Date)?{
        didSet{
            reload(updateData: false)
        }
    }
    var dataType: BTBoundDataType = .Yield
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'dataType' instead.")
    @IBInspectable var dataTypeName: String? {
        willSet {
            if let newDataType = BTBoundDataType(rawValue: newValue?.lowercased() ?? "") {
                dataType = newDataType
            }
        }
    }
    
    @IBInspectable var lineWidth: Float = 1.5
    
    @IBInspectable var chartColor: UIColor = UIColor.black
    
    var boundName: String?{
        didSet{
            if boundName != nil {
               print("set bound name " + boundName!)
            }
        }
    }
    
    var dataProviderType: BTBoundDataProviderType = .local{
        didSet{
            setDataProvider()
        }
    }
    @IBInspectable var apiUrlPath: String?
    
    private var _dataProvider: BTBoundDataProviderProtocol?
    private var _busyIndicator: UIActivityIndicatorView?
    private var _data = [BTBoundValue] ()
    private var _chart: Chart?
    
    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDataProvider()
        
        let indicatorSize = 44.0
        _busyIndicator = UIActivityIndicatorView.init(frame: CGRect.init(origin: self.center,
                                                                         size: CGSize.init(width: indicatorSize,
                                                                                           height: indicatorSize)))
        _busyIndicator?.center = self.center
        _busyIndicator?.style = .gray
        _busyIndicator?.hidesWhenStopped = true
         self.addSubview(_busyIndicator!)
    }
    
    private func initChart() -> Chart?{
        
        if _data.count == 0 {
            return nil
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM"
        
        let dataValues = self._data.map {($0.date, $0.yield)}
        let chartPoints: [ChartPoint] = dataValues.map {ChartPoint(x:ChartAxisValueDate.init(date: $0.0, formatter: displayFormatter), y:  ChartAxisValueDouble($0.1))
        }

        let labelSettings = ChartLabelSettings(font: BTChartDefaults.labelFont)
        
        var yMin =  dataValues.map {$0.1}.min() ?? 0
        let yMax =  dataValues.map {$0.1}.max() ?? 0
        let interval = yMax - yMin
        let generator = ChartAxisGeneratorMultiplier(round((yMax - yMin)/10))
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: String(format: "%.f", scalar), settings: labelSettings)
        }
        
        let xGeneratorDate = ChartAxisValuesGeneratorDate(unit: .day,
                                                          preferredDividers:6,
                                                          minSpace: 1,
                                                          maxTextSize: 12)
        let xLabelGeneratorDate = ChartAxisLabelsGeneratorDate(labelSettings: labelSettings,
                                                               formatter: displayFormatter)
        let firstDate =  dataValues.map {$0.0}.min()!
        let lastDate = dataValues.map {$0.0}.max()!
        let period = lastDate.timeIntervalSince1970 - firstDate.timeIntervalSince1970
        let xModel = ChartAxisModel(firstModelValue: firstDate.timeIntervalSince1970 - period/10,
                                    lastModelValue: lastDate.timeIntervalSince1970 + period/10,
                                    axisTitleLabels: [ChartAxisLabel(text: "", settings: labelSettings)],
                                    axisValuesGenerator: xGeneratorDate, labelsGenerator: xLabelGeneratorDate)

        let yModel = ChartAxisModel(firstModelValue: yMin - interval/10,
                                    lastModelValue: yMax + interval/10,
                                    axisTitleLabels: [ChartAxisLabel(text: self.boundName?.uppercased() ?? "", settings: labelSettings.defaultVertical())],
                                    axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        let chartFrame = BTChartDefaults.chartFrame(self.bounds)
        
        let chartSettings = BTChartDefaults.iPhoneChartSettings
        
        // generate axes layers and calculate chart inner frame, based on the axis models
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        // create layer with guidelines
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth:  BTChartDefaults.guidelinesWidth)
        let guidelinesLayer =  ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: self.chartColor, lineWidth:CGFloat(self.lineWidth), animDuration: 0, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], useView: false)
        
        // view generator - this is a function that creates a view for each chartpoint
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let viewSize: CGFloat = Env.iPad ? 30 : 20
            let center = chartPointModel.screenLoc
            let label = UILabel(frame: CGRect(x: center.x - viewSize / 2, y: center.y - viewSize / 2, width: viewSize, height: viewSize))
            label.backgroundColor = UIColor.clear
            label.textAlignment = NSTextAlignment.center
            label.text = chartPointModel.chartPoint.y.description
            label.font = BTChartDefaults.labelFont
            return label
        }
        
        // create layer that uses viewGenerator to display chartpoints
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: viewGenerator, mode: .translate)
        
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLineLayer,
                chartPointsLayer,
            ]
        )
        
        return chart
    }
    
    private func setDataProvider(){
        switch dataProviderType {
        case .http:
             if let apiPath = self.apiUrlPath {
               _dataProvider = BTBoundHTTPDataProvider(endpointApiPath: apiPath)
             }
            break
        case .webSoket:
            _dataProvider = BTBoundWebSoketDataProvider()
            break
        default:
             _dataProvider = BTBoundTestDataProvider()
            break
        }  
    }
    
    func reload(){
        reload(updateData: true)
    }
    
    private func reload(updateData: Bool){
 
        if updateData == true {
            if  let boundID = self.boundName,
                let fromDate = self.viewDatePeriod?.from,
                let toDate = self.viewDatePeriod?.to {
                
                _busyIndicator?.startAnimating()
                _dataProvider?.getBounds(forName: boundID,
                                         fromDate: fromDate,
                                         toDate: toDate,
                                         completion: { [weak self] (results) in
                                            self?._data = results
                                            DispatchQueue.main.async {  [weak self] in
                                                self?._busyIndicator?.stopAnimating()
                                                self?.updateUI()
                                            }
                                            
                    }, fail: { [weak self] (error) in
                        print(error.localizedDescription)
                        DispatchQueue.main.async {  [weak self] in
                            self?._busyIndicator?.stopAnimating()
                            self?.showDialogController(title:  "Ошибка".localized,
                                                      message: error.localizedDescription,
                                                      cancel: nil,
                                                      success: nil)
                        }
                })
            }
        }
        else{
           updateUI()
        }
    }
    
    private func updateUI(){
        print("data: \(_data)")
        
        if _chart != nil {
            _chart!.view.removeFromSuperview()
        }
        
        if _data.count > 0 {
          _chart = initChart()
          self.addSubview(_chart!.view)
        }
        
    }
    
    private func showDialogController(title: String,
                                      message: String,
                                      cancelTitle: String? = "Отмена".localized,
                                      cancel: (()->())?,
                                      succesTtitle: String? = "Ок".localized,
                                      success: (()->())?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancel != nil {
            alertController.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { (action: UIAlertAction) in
                cancel?()
            })
        }
        
        alertController.addAction(UIAlertAction(title: succesTtitle, style: .default) { (action: UIAlertAction) in
            success?()
        })
    
        alertController.show(true)
    }
}
