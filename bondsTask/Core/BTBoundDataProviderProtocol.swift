//
//  BTBoundDataProviderProtocol.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import Foundation
import DateToolsSwift

protocol BTBoundDataProviderProtocol: class{
    func getBounds(forName boundName: String,
                   fromDate: Date,
                   toDate: Date,
                   completion: @escaping ([BTBoundValue]) -> (),
                   fail: @escaping (Error) -> ())
}

class BTBoundTestDataProvider: NSObject, BTBoundDataProviderProtocol{
    
    func getBounds(forName boundName: String,
                   fromDate: Date,
                   toDate: Date,
                   completion: @escaping ([BTBoundValue]) -> (),
                   fail: @escaping (Error) -> ()) {
        
        var results = [BTBoundValue]()
        let resultsCount = Int.random(in: 50..<200)
        let timePeriod = TimeChunk.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks:0, months: 0, years: 2)
        let timeInterval = Double(timePeriod.to(TimeUnits.seconds)/resultsCount)
        var date = Date().subtract(timePeriod)
        for _ in 0..<resultsCount {
            let value = BTBoundValue.init(aYield: Double.random(in: 80.0..<200.0),
                                          aPrice: Double.random(in: 1.0..<1000.0),
                                          aDate: date)
            date = date.addingTimeInterval(timeInterval)
            results.append(value)
        }
        completion(results)
    }
}
