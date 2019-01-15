//
//  ViewController.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import UIKit
import DateToolsSwift

private let btAPIURLPath = "https://46009.selcdn.ru/skyBounds"

enum BTPeriodControlType: Int{
    case W1, M1, M3, M6, Y1, Y2
    
    var timeChunk: TimeChunk{
 
        switch self {
        case .M1:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 1, years: 0)

        case .M3:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 3, years: 0)

        case .M6:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 6, years: 0)
     
        case .Y1:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 0, years: 1)
        
        case .Y2:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 0, years: 2)
        
        default:
            return TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:1, months: 0, years: 0)
        }
    }
}

class BTViewController: UIViewController {
    
    @IBOutlet var periodSelector: UISegmentedControl!
    @IBOutlet var boundGraph: BTBoundGraphView!
    @IBOutlet var fieldTypeView: UIView!
    @IBOutlet var fieldTypeButton: UIButton!
    @IBOutlet var dataTypePicker: UIPickerView!
    @IBOutlet var dataTypePickerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       configureBoundGraph()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        boundGraph.reload()
    }
    
    
    //MARK: -
    
    private func configureBoundGraph(){
        
        boundGraph.apiUrlPath = btAPIURLPath
        boundGraph.boundName = "isin"
        boundGraph.dataType = .Yield//.Price
        boundGraph.dataProviderType = .http//.local
        
        let period = BTPeriodControlType.Y1
        changeBoundPeriod(periodType: period)
        periodSelector.selectedSegmentIndex = period.rawValue
    }
    
    private func changeBoundPeriod(periodType: BTPeriodControlType){
        
        boundGraph.setDatePeriod(datePeriod: periodType.timeChunk, toDate: Date())
    }
    
    //MARK: - actions
    
    @IBAction func periodSegmentControlChanged(_ sender: UISegmentedControl){
        
        changeBoundPeriod(periodType: BTPeriodControlType.init(rawValue: sender.selectedSegmentIndex)!)
    }
    
    @IBAction func fieldTypeButtonTap(_ sender: Any){
        dataTypePickerView.isHidden = false
    }
    
    @IBAction func doneButtonTap(_ sender: Any){
        dataTypePickerView.isHidden = true
        let selectedIndex = dataTypePicker.selectedRow(inComponent: 0)
        if selectedIndex >= 0 {
           boundGraph.dataType = BTBoundDataType.init(rawValue: boundGraph.allDataFields[selectedIndex])!
        }
    }

    @IBAction func cancelButtonTap(_ sender: Any){
        dataTypePickerView.isHidden = true
    }
}

extension BTViewController: BTBoundGraphViewDelegate{
    func graphDidChangedDataType() {
        fieldTypeButton.setTitle(boundGraph.dataTypeName, for: .normal)
    }
}

extension BTViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    //MARK: UIPickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return boundGraph.allDataFields.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
 
        let title = NSAttributedString(string: boundGraph.allDataFields[row],
                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return title
    }
    
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }

}

