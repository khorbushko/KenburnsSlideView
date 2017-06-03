//
//  SlideTileView.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

final class SlideTileView : BaseView {
    
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
    
    func updateWithTile(_ tile:SlideTileObject) {
        titleLabel.text = tile.title
    }
    
    // MARK: - Private
    
    fileprivate func prepareTileForReuse() {
        titleLabel.text = ""
    }
    
    fileprivate func configureTile(_ slideTileObject:SlideTileObject?) {
        prepareTileForReuse()
        if let object = slideTileObject {
            titleLabel.text = object.title
        }
    }
    
    fileprivate func prepareSubviews() {
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 25)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "subview" : titleLabel
        ]
        addSubview(titleLabel)
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subview]-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-350-[subview]-100-|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activate(constraints)
    }
    
}
