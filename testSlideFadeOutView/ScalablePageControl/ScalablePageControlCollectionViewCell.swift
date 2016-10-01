//
//  ScalablePageControlCollectionViewCell.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

final class ScalablePageControlCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet private weak var fakeDotView: UIView!
    private let InitialTransformScale:CGFloat = 0.3
    
    var isSelectedPage:Bool = false {
        didSet {
            if isSelectedPage == true {
                fakeDotView.transform = CGAffineTransformIdentity
            } else {
                fakeDotView.transform = CGAffineTransformMakeScale(InitialTransformScale, InitialTransformScale)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fakeDotView.layer.cornerRadius = 5
        fakeDotView.layer.borderWidth = 1
        fakeDotView.layer.borderColor = fakeDotView.backgroundColor?.CGColor
        fakeDotView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fakeDotView.transform = isSelectedPage ? CGAffineTransformIdentity : CGAffineTransformMakeScale(InitialTransformScale, InitialTransformScale)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isSelectedPage = false
    }
    
    // MARK: - Public
    
//    func markAsCurrent(current:Bool = true) {
//        fakeDotView.transform = current == true ? CGAffineTransformIdentity : CGAffineTransformMakeScale(InitialTransformScale, InitialTransformScale)
//    }
    
    func applyTransformWithProgress(progress:CGFloat) {
        let transform = (1 - InitialTransformScale) * progress
        fakeDotView.transform = CGAffineTransformMakeScale(InitialTransformScale + transform, InitialTransformScale + transform)
    }
    
}
