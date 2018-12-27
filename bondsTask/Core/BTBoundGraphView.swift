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
    
    @IBInspectable var boundName: String?{
        didSet(newValue){
            if newValue != nil {
               print("set bound name " + newValue!)
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
    
    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDataProvider()
        boundName = ""
       
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
            _dataProvider = BTBoundHTTPDataProvider()
        case .webSoket:
            _dataProvider = BTBoundWebSoketDataProvider()
        default:
           _dataProvider = BTBoundLocalDataProvider()
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
                                            DispatchQueue.main.async {
                                                self?._busyIndicator?.stopAnimating()
                                                self?.updateUI()
                                            }
                                            
                    }, fail: { [weak self] (error) in
                        DispatchQueue.main.async {
                            self?._busyIndicator?.stopAnimating()
                        }
                        print(error.localizedDescription)
                })
            }
        }
        else{
           updateUI()
        }
    }
    
    private func updateUI(){
        
    }
}
