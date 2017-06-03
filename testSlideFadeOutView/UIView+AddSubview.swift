//
//  UIView+AddSubview.swift
//  
//
//  Created by Kirill Gorbushko on 13.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: - UIView+AddSubview
    
    func addSubviewWithConstraints(_ subview:UIView, offset:Bool = true) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "subview" : subview
        ]
        addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: offset ? "H:|-[subview]-|" : "H:|[subview]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: offset ? "V:|-[subview]-|" : "V:|[subview]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activate(constraints)
    }
}
