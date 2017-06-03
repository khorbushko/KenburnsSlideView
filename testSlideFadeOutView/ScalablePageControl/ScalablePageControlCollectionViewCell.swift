//
//  ScalablePageControlCollectionViewCell.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

final class ScalablePageControlCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet fileprivate weak var fakeDotView: UIView!
    fileprivate let InitialTransformScale:CGFloat = 0.3
    
    var isSelectedPage:Bool = false {
        didSet {
            if isSelectedPage == true {
                fakeDotView.transform = CGAffineTransform.identity
            } else {
                fakeDotView.transform = CGAffineTransform(scaleX: InitialTransformScale, y: InitialTransformScale)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fakeDotView.layer.cornerRadius = 5
        fakeDotView.layer.borderWidth = 1
        fakeDotView.layer.borderColor = fakeDotView.backgroundColor?.cgColor
        fakeDotView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fakeDotView.transform = isSelectedPage ? CGAffineTransform.identity : CGAffineTransform(scaleX: InitialTransformScale, y: InitialTransformScale)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isSelectedPage = false
    }
    
    // MARK: - Public
    
//    func markAsCurrent(current:Bool = true) {
//        fakeDotView.transform = current == true ? CGAffineTransformIdentity : CGAffineTransformMakeScale(InitialTransformScale, InitialTransformScale)
//    }
    
    func applyTransformWithProgress(_ progress:CGFloat) {
        let transform = (1 - InitialTransformScale) * progress
        fakeDotView.transform = CGAffineTransform(scaleX: InitialTransformScale + transform, y: InitialTransformScale + transform)
    }
    
}
