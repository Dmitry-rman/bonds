//
//  BTBoundGraphView.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import UIKit

enum BTBoundDataType: String {
    case Yield = "yield"
    case Price = "price"
}

enum BTBoundDataProviderType: Int{
    case local
    case http
    case webSoket
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
                                            DispatchQueue.main.async {
                                                self?._busyIndicator?.stopAnimating()
                                                self?.updateUI()
                                            }
                                            
                    }, fail: { [weak self] (error) in
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
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
