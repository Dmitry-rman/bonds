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

class ViewController: UIViewController {
    
    @IBOutlet var boundGraph: BTBoundGraphView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       configureBoundGraph()
    }
    
    private func configureBoundGraph(){
        
        boundGraph.apiUrlPath = btAPIURLPath
        //boundGraph.dataProviderType = .http
        
        let currentDate = Date.init()
        let fromDate = currentDate.subtract(TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 4, years: 0))
        boundGraph.viewDatePeriod = (from: fromDate, to: currentDate)
        
        boundGraph.reload()
    }

}

