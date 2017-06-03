//
//  SlideScrollView.swift
//
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

protocol SlideScrollViewDelegate {
    func slideScrollView(_ scrollView:SlideScrollView, didShowNextItem nextItem:Int, currentItem:Int)
    func slideScrollView(_ scrollView:SlideScrollView, didShowPreviousItem previousItem:Int, currentItem:Int)
}

final class SlideScrollView: UIScrollView {
    
    var slideDelegate:SlideScrollViewDelegate?
    
    var currentItem:Int = 0
    var fadeDuration = 0.3
    
    fileprivate var animationInProgress:Bool = false
    
    // MARK: - LifeCycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if animationInProgress == false {
            recenterContentIfNeeded()
        }
    }
    
    // MARK: - Public
    
    func setContentOffset(_ contentOffset: CGPoint, slowAnimated: Bool) {
        if slowAnimated == true {
            animationInProgress = true
            UIView.animate(withDuration: fadeDuration, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction ], animations: {
                super.setContentOffset(contentOffset, animated: false)
                }, completion: { (_) in
                    self.animationInProgress = false
                    self.recenterContentIfNeeded()
            })
        } else {
            super.setContentOffset(contentOffset, animated: false)
        }
    }
    
    // MARK: - Private
    
    fileprivate func recenterContentIfNeeded() {

        //without infinite

//        if currentItem >= 2 { //count - 2
//            return
//        }
        
        //without
        
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let contentOffsetX:CGFloat = (contentWidth - bounds.size.width) / 2
        let distanceToCenter = currentOffset.x - contentOffsetX
        
        if distanceToCenter > 0 {
            //next
            if distanceToCenter >= bounds.width {
                contentOffset = CGPoint(x: CGFloat(ceilf(Float(contentOffsetX))), y: currentOffset.y)
                let nextItem = currentItem + 2
                slideDelegate?.slideScrollView(self, didShowNextItem: nextItem, currentItem: currentItem)
                currentItem += 1
            }
        } else {
            //prev
            if distanceToCenter <= -bounds.width {
                contentOffset = CGPoint(x: CGFloat(ceilf(Float(contentOffsetX))), y: currentOffset.y)
                let prevItem = currentItem - 2
                slideDelegate?.slideScrollView(self, didShowPreviousItem: prevItem, currentItem: currentItem)
                currentItem -= 1
            }
        }
    }
}
