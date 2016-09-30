//
//  UIView+AddSubview.swift
//  SuavooClient
//
//  Created by Kirill Gorbushko on 13.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: - UIView+AddSubview
    
    func addSubviewWithConstraints(subview:UIView, offset:Bool = true) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "subview" : subview
        ]
        addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat(offset ? "H:|-[subview]-|" : "H:|[subview]|", options: [.AlignAllLeading, .AlignAllTrailing], metrics: nil, views: views)
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(offset ? "V:|-[subview]-|" : "V:|[subview]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(constraints)
    }
}
