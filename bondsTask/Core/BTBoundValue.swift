//
//  BTBound.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import Foundation

struct BTBoundValue: Codable{
    var date: Date
    var yield: Double
    var price: Double
    
    init(aYield: Double, aPrice: Double, aDate: Date) {
        self.yield = aYield
        self.price = aPrice
        self.date = aDate
    }
}
