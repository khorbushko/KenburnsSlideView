//
//  BaseView.swift
//  
//
//  Created by Kirill Gorbushko on 26.09.16.
//  Copyright © 2016 Suavoo. All rights reserved.
//

import UIKit

class BaseView : UIView {
    
    // MARK: - LifeCycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareView()
    }
    
    // MARK: - Private
    fileprivate func prepareView() {
        let xibName = self.classForCoder.description().components(separatedBy: ".").last
        if xibName != nil {
            let nibs = Bundle.main.loadNibNamed(xibName!, owner: self, options: nil)
            if let view = nibs?.first as? UIView {
                view.backgroundColor = UIColor.clear
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubviewWithConstraints(view, offset: false)
            }
        }
    }
}
