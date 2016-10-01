//
//  SliderView.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

protocol SlideViewDelegate {
    func slideView(slideView:SlideView, downloadImageURL:NSURL, completion:((image:UIImage)->Void))
    func slideView(slideView:SlideView, didScrollToProgress:CGFloat, transition:Transition, currentPage:Int)
    func slideView(slideView:SlideView, didShowItem displayItem:Int)
}

final class SlideView: BaseView {
    
    private enum Order:Int {
        case Previous = 0
        case Current = 1
        case Next = 2
    }
    
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var scrollView: SlideScrollView!
    
    private var coverView:UIView! = UIView()
    private var gradientLayer:CAGradientLayer = CAGradientLayer()
    
    private var imageViews:NSMutableArray = []  //views with images
    private var tileViews:NSMutableArray = []   //objects to display each view info
    
    var delegate:SlideViewDelegate?
    var currentPage:Int = 0
    var imagesData: [SlideTileObject] = [] {    //objects to hold each view info
        didSet {
            updateImages()
        }
    }
    
    private var currentDisplayItem:Int = 0
    
    var previousDirection:Transition = .Unknown
    var stabilityCounter:Int = 0

    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        prepareView()
    }
    
    // MARK: - Private
    
    private func prepareView() {
        for view in imageViews {
            view.removeFromSuperview()
        }
        imageViews.removeAllObjects()
        
        for view in tileViews {
            view.removeFromSuperview()
        }
        tileViews.removeAllObjects()
        
        scrollView.contentSize = CGSizeMake(bounds.width * 3, bounds.height)
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.contentOffset = CGPointMake(bounds.width, 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.directionalLockEnabled = true
        scrollView.slideDelegate = self
        
        for item in 0..<3 {
            let view = UIImageView(frame: bounds)
            imageViews.insertObject(view, atIndex: 0)
            rootView.insertSubview(view, belowSubview: scrollView)
            
            var rect = bounds
            rect.origin.x = bounds.width * CGFloat(item)
            let tileView = SlideTileView(frame: rect)
            tileView.backgroundColor = UIColor.clearColor()
            tileViews.addObject(tileView)
    
            scrollView.addSubview(tileView)
        }
        
        gradientLayer.removeFromSuperlayer()
        let rect = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
        gradientLayer.frame = rect
        gradientLayer.colors = [
            UIColor.grayColor().colorWithAlphaComponent(0.1).CGColor,
            UIColor.grayColor().colorWithAlphaComponent(0.4).CGColor,
            UIColor.whiteColor().colorWithAlphaComponent(0.9).CGColor
        ]
        gradientLayer.locations = [0.4, 0.6, 1]
        scrollView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        coverView.removeFromSuperview()
        coverView = UIView(frame: bounds)
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        coverView.alpha = 0
        addSubview(coverView)
        
        updateImages()
    }
    
    private func updateImages(selectedIndex:Int = 0) {
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.Current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.Previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.Next.rawValue] as? UIImageView,
                
                let currentImage = tileAtIndex(selectedIndex),
                let nextImage = tileAtIndex(selectedIndex+1),
                let prevImage = tileAtIndex(selectedIndex-1) {
                
                updateImage(currentImage, forView: currentView)
                updateImage(nextImage, forView: nextView)
                updateImage(prevImage, forView: previousView)
                
                rootView.insertSubview(nextView, atIndex: 0)
                rootView.insertSubview(currentView, atIndex: 2)
                rootView.insertSubview(previousView, atIndex: 1)
            }
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.Current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.Previous.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.Next.rawValue] as? SlideTileView,
                
                let currentImage = tileAtIndex(selectedIndex),
                let nextImage = tileAtIndex(selectedIndex+1),
                let prevImage = tileAtIndex(selectedIndex-1){
                
                currentTile.titleLabel.text = currentImage.title
                previousTile.titleLabel.text = prevImage.title
                nextTile.titleLabel.text = nextImage.title
            }
        }
        
    }
    
    private func updateImage(tileDataObject:SlideTileObject, forView currentImageView:UIImageView) {
        if let image = tileDataObject.image {
            currentImageView.image = image
        } else {
            if let url = tileDataObject.imageURL {
                delegate?.slideView(self, downloadImageURL: url, completion: { (image) in
                    currentImageView.image = image
                })
            }
        }
    }
    
    private func tileAtIndex(tileIndex:Int) -> SlideTileObject? {
        if imagesData.count == 0 {
            return nil
        }
        let selectedTile = imagesData[validateItemIndex(tileIndex)]
        return selectedTile
    }
    
    private func validateItemIndex(itemIndex:Int) -> Int {
        if (itemIndex < 0) {
            let item = imagesData.count - abs(itemIndex % imagesData.count)
            return item == imagesData.count ? 0 : item
        } else if (imagesData.count <= itemIndex) {
            let item = (itemIndex % (imagesData.count))
            return item
        } else {
            return itemIndex
        }
    }
}

extension SlideView: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            let width = bounds.width
            let diff = (scrollView.contentOffset.x - width) / width
            var alpha = cos(Double((180 * fabsf(Float(diff)) )) * M_PI / 180.0)/2 + 0.5
            if (alpha > 0.999) {
                alpha = 1.0
            }
            
            let gradientAlpha = sin (Double((180 * fabsf(Float(diff)) )) * M_PI / 180.0) - 0.4
            coverView.alpha = CGFloat(gradientAlpha)
            
            if imageViews.count == 3 {
                if let currentView = imageViews[Order.Current.rawValue] as? UIImageView,
                    let previousView = imageViews[Order.Previous.rawValue] as? UIImageView,
                    let nextView = imageViews[Order.Next.rawValue] as? UIImageView {
                    
                    var direction:Transition = .Next
                    if (scrollView.contentOffset.x - width) < 0 {
                        //drag right
                        currentView.alpha = CGFloat(alpha)
                        previousView.alpha = 1
                        nextView.alpha = 0
                        
                        direction = .Previous
                    } else {
                        //drag left
                        currentView.alpha = CGFloat(alpha)
                        previousView.alpha = 0
                        nextView.alpha = 1
                        
                        direction = .Next
                    }
                    
                    if previousDirection == .Unknown {
                        previousDirection = direction
                    }
                    if previousDirection != direction {
                        stabilityCounter += 1
                        if stabilityCounter == 7 {
                            previousDirection = direction
                            stabilityCounter = 0
                        }
                    }
                    
                    delegate?.slideView(self, didScrollToProgress: CGFloat(1 - alpha), transition: previousDirection, currentPage: currentDisplayItem)
                }
            }
            
            if tileViews.count == 3 {
                if let currentTile = tileViews[Order.Current.rawValue] as? SlideTileView,
                    let previousTile = tileViews[Order.Previous.rawValue] as? SlideTileView,
                    let nextTile = tileViews[Order.Next.rawValue] as? SlideTileView {
                    
                    currentTile.titleLabel.alpha = CGFloat(alpha)
                    previousTile.titleLabel.alpha = CGFloat(1 - alpha)
                    nextTile.titleLabel.alpha = CGFloat(1 - alpha)
                }
            }
            
        }
    }
}

extension SlideView: SlideScrollViewDelegate {
    // MARK: - SlideScrollViewDelegate
    func slideScrollView(scrollView:SlideScrollView, didShowNextItem nextItem:Int, currentItem:Int) {
        currentPage = currentItem
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.Current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.Previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.Next.rawValue] as? UIImageView {
                
                updatePreviousView(currentView)
                updateCurrentView(nextView)
                updateNextView(previousView)
                
                if let currentTile = tileAtIndex(nextItem),
                    let nextView = imageViews[Order.Next.rawValue] as? UIImageView {
                    updateImage(currentTile, forView: nextView)
                }
            }
            updateVisibilityPosition()
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.Current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.Previous.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.Next.rawValue] as? SlideTileView,
                
                let currentImage = tileAtIndex(currentItem + 1),
                let nextImage = tileAtIndex(nextItem),
                let prevImage = tileAtIndex(currentItem){
                
                currentTile.updateWithTile(currentImage)
                previousTile.updateWithTile(prevImage)
                nextTile.updateWithTile(nextImage)
            }
        }
        currentDisplayItem += 1
        delegate?.slideView(self, didShowItem: currentDisplayItem)
    }
    
    private func updatePreviousView(view:UIImageView) {
        imageViews.replaceObjectAtIndex(Order.Previous.rawValue, withObject: view)
    }
    private func updateCurrentView(view:UIImageView) {
        imageViews.replaceObjectAtIndex(Order.Current.rawValue, withObject: view)
    }
    private func updateNextView(view:UIImageView) {
        imageViews.replaceObjectAtIndex(Order.Next.rawValue, withObject: view)
    }
    
    func slideScrollView(scrollView:SlideScrollView, didShowPreviousItem previousItem:Int, currentItem:Int) {
        currentPage = currentItem
        
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.Current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.Previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.Next.rawValue] as? UIImageView {
                
                updatePreviousView(nextView)
                updateCurrentView(previousView)
                updateNextView(currentView)
                
                if let currentImage = tileAtIndex(previousItem),
                    let previousView = imageViews[Order.Previous.rawValue] as? UIImageView {
                    updateImage(currentImage, forView: previousView)
                }
                updateVisibilityPosition()
            }
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.Current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.Next.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.Previous.rawValue] as? SlideTileView,
                
                let currentImage = tileAtIndex(currentItem - 1),
                let nextImage = tileAtIndex(previousItem),
                let prevImage = tileAtIndex(currentItem){
                
                currentTile.updateWithTile(currentImage)
                previousTile.updateWithTile(prevImage)
                nextTile.updateWithTile(nextImage)
            }
        }
        
        currentDisplayItem -= 1
        delegate?.slideView(self, didShowItem: currentDisplayItem)
    }
    
    private func updateVisibilityPosition() {
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.Current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.Previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.Next.rawValue] as? UIImageView {
                
                previousView.alpha = 0
                currentView.alpha = 1
                nextView.alpha = 0
                
                rootView.insertSubview(nextView, atIndex: 0)
                rootView.insertSubview(currentView, atIndex: 2)
                rootView.insertSubview(previousView, atIndex: 1)
            }
        }
    }
    
}
