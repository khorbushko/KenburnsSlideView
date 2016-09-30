//
//  BaseView.swift
//  SuavooClient
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
    
    // MARK: - Private
    private func prepareView() {
        let xibName = self.classForCoder.description().componentsSeparatedByString(".").last
        if xibName != nil {
            let nibs = NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: nil)
            if let view = nibs.first as? UIView {
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubviewWithConstraints(view, offset: false)
            }
        }
    }
}
