//
//  BTBoundHTTPDataProvider.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import Foundation

class BTBoundHTTPDataProvider: NSObject, BTBoundDataProviderProtocol{
    
    func getBounds(forName boundName: String, fromDate: Date, toDate: Date, completion: ([BTBoundValue]) -> (), fail: (NSError) -> ()) {
        completion([])
    }

}
