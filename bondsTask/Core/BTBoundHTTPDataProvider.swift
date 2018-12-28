//
//  BTBoundHTTPDataProvider.swift
//  bondsTask
//
//  Created by Dmitry Kudryavtsev on 27/12/2018.
//  Copyright © 2018 Dmitry Kudryavtsev. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire
import AlamofireNetworkActivityLogger

public class BTBoundHTTPDataProvider: NSObject, BTBoundDataProviderProtocol{

    var apiPath: String
    
    init(endpointApiPath: String) {
        apiPath = endpointApiPath
        
        #if DEBUG
          NetworkActivityLogger.shared.level = .debug
          NetworkActivityLogger.shared.startLogging()
        #endif
    }
    
    func getBounds(forName boundName: String, fromDate: Date, toDate: Date, completion: @escaping ([BTBoundValue]) -> (), fail: @escaping (Error) -> ()) {
      
        let url = URL.init(string: apiPath)!.appendingPathComponent("bounds_" + boundName + ".json")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        Alamofire.request(url).responseDecodableObject(keyPath: "data.values", decoder: decoder) { (response: DataResponse<[BTBoundValue]>) in
            
            if response.result.isSuccess == true {
              let bounds = response.result.value
              completion(bounds ?? [])
            }
            else{
                fail(response.result.error!)
            }
        }
        
    }

}
