//
//  SlideTileView.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

//for subclassing

class SlideTileView : UIView {
    
    var titleLabel:UILabel = UILabel()
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareSubviews()
    }
    
    // MARK: - Public
    
    func updateWithTile(tile:SlideTileObject) {
        titleLabel.text = tile.title
    }
    
    func prepareTileForReuse() { //<- override Point. DO NOT CALL SUPER
        titleLabel.text = ""
    }
    
    func configureTile(slideTileObject:SlideTileObject?) { //<- override Point DO NOT CALL SUPER
        if let object = slideTileObject {
            titleLabel.text = object.title
        }
    }
    
    func prepareSubviews() { //<- override Point DO NOT CALL SUPER
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(25)
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "subview" : titleLabel
        ]
        addSubview(titleLabel)
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[subview]-|", options: [.AlignAllLeading, .AlignAllTrailing], metrics: nil, views: views)
        constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-350-[subview]-100-|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activateConstraints(constraints)
    }
}
