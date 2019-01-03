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

enum PeriodControlType: Int{
    case W1, M1, M3, M6, Y1, Y2
}

class BTViewController: UIViewController {
    
    @IBOutlet var periodSelector: UISegmentedControl!
    @IBOutlet var boundGraph: BTBoundGraphView!
    @IBOutlet var fieldTypeView: UIView!
    @IBOutlet var fieldTypeButton: UIButton!
    @IBOutlet var dataTypePickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       configureBoundGraph()
       fieldTypeButton.setTitle(boundGraph.dataTypeName, for: .normal)
    }
    
    private func configureBoundGraph(){
        
        boundGraph.apiUrlPath = btAPIURLPath
        boundGraph.boundName = "isin"
        boundGraph.dataProviderType = .http
        
        let period = PeriodControlType.Y1
        changeBoundPeriod(periodType: period)
        periodSelector.selectedSegmentIndex = period.rawValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        boundGraph.reload()
    }
    
    func changeBoundPeriod(periodType: PeriodControlType){
        
        var timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:1, months: 0, years: 0)
        
        switch periodType {
        case .M1:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 1, years: 0)
            break
        case .M3:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 3, years: 0)
            break
        case .M6:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 6, years: 0)
            break
        case .Y1:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 0, years: 1)
            break
        case .Y2:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 0, years: 2)
            break
        default:
            timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:1, months: 0, years: 0)
            break
        }
        
        boundGraph.setDatePeriod(datePeriod: timePeriod, toDate: Date())
    }
    
    //MARK: -
    
    @IBAction func periodSegmentControlChanged(_ sender: UISegmentedControl){
        
        changeBoundPeriod(periodType: PeriodControlType.init(rawValue: sender.selectedSegmentIndex)!)
    }
    
    @IBAction func fieldTypeButtonTap(_ sender: Any){
        dataTypePickerView.isHidden = false
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return boundGraph.allDataFields[row]
    }
    
    //MARK: UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        boundGraph.dataType = BTBoundDataType.init(rawValue: boundGraph.allDataFields[row])!
        dataTypePickerView.isHidden = true
    }

}

