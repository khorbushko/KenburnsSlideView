//
//  SliderView.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

protocol SlideViewDelegate {
    func slideView(_ slideView:SlideView, downloadImageURL:URL, completion:((_ image:UIImage)->Void))
    func slideView(_ slideView:SlideView, didScrollToProgress:CGFloat, transition:Transition, currentPage:Int)
    func slideView(_ slideView:SlideView, didShowItem displayItem:Int)
}

final class SlideView: BaseView {
    
    fileprivate enum Order:Int {
        case previous = 0
        case current = 1
        case next = 2
    }
    
    @IBOutlet fileprivate weak var rootView: UIView!
    @IBOutlet fileprivate weak var scrollView: SlideScrollView!
    
    fileprivate var coverView:UIView! = UIView()
    fileprivate var gradientLayer:CAGradientLayer = CAGradientLayer()
    
    fileprivate var imageViews:NSMutableArray = []  //views with images
    fileprivate var tileViews:NSMutableArray = []   //objects to display each view info
    
    var delegate:SlideViewDelegate?
    var currentPage:Int = 0
    var imagesData: [SlideTileObject] = [] {    //objects to hold each view info
        didSet {
            updateImages()
        }
    }
    
    fileprivate var currentDisplayItem:Int = 0
    
    var previousDirection:Transition = .unknown
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
    
    fileprivate func prepareView() {
        for view in imageViews {
            (view as AnyObject).removeFromSuperview()
        }
        imageViews.removeAllObjects()
        
        for view in tileViews {
            (view as AnyObject).removeFromSuperview()
        }
        tileViews.removeAllObjects()
        
        scrollView.contentSize = CGSize(width: bounds.width * 3, height: bounds.height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentOffset = CGPoint(x: bounds.width, y: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.slideDelegate = self
        
        for item in 0..<3 {
            let view = UIImageView(frame: bounds)
            imageViews.insert(view, at: 0)
            rootView.insertSubview(view, belowSubview: scrollView)
            
            var rect = bounds
            rect.origin.x = bounds.width * CGFloat(item)
            let tileView = SlideTileView(frame: rect)
            tileView.backgroundColor = UIColor.clear
            tileViews.add(tileView)
    
            scrollView.addSubview(tileView)
        }
        
        gradientLayer.removeFromSuperlayer()
        let rect = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        gradientLayer.frame = rect
        gradientLayer.colors = [
            UIColor.gray.withAlphaComponent(0.1).cgColor,
            UIColor.gray.withAlphaComponent(0.4).cgColor,
            UIColor.white.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.locations = [0.4, 0.6, 1]
        scrollView.layer.insertSublayer(gradientLayer, at: 0)
        
        coverView.removeFromSuperview()
        coverView = UIView(frame: bounds)
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        coverView.alpha = 0
//        addSubview(coverView)
        
        updateImages()
    }
    
    fileprivate func updateImages(_ selectedIndex:Int = 0) {
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.next.rawValue] as? UIImageView,
                
                let currentImage = tileAtIndex(selectedIndex),
                let nextImage = tileAtIndex(selectedIndex+1),
                let prevImage = tileAtIndex(selectedIndex-1) {
                
                updateImage(currentImage, forView: currentView)
                updateImage(nextImage, forView: nextView)
                updateImage(prevImage, forView: previousView)
                
                rootView.insertSubview(nextView, at: 0)
                rootView.insertSubview(currentView, at: 2)
                rootView.insertSubview(previousView, at: 1)
            }
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.previous.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.next.rawValue] as? SlideTileView,
                
                let currentImage = tileAtIndex(selectedIndex),
                let nextImage = tileAtIndex(selectedIndex+1),
                let prevImage = tileAtIndex(selectedIndex-1){
                
                currentTile.titleLabel.text = currentImage.title
                previousTile.titleLabel.text = prevImage.title
                nextTile.titleLabel.text = nextImage.title
            }
        }
        
    }
    
    fileprivate func updateImage(_ tileDataObject:SlideTileObject, forView currentImageView:UIImageView) {
        if let image = tileDataObject.image {
            currentImageView.image = image
        } else {
            if let url = tileDataObject.imageURL {
                delegate?.slideView(self, downloadImageURL: url as URL, completion: { (image) in
                    currentImageView.image = image
                })
            }
        }
    }
    
    fileprivate func tileAtIndex(_ tileIndex:Int) -> SlideTileObject? {
        if imagesData.count == 0 {
            return nil
        }
        let selectedTile = imagesData[validateItemIndex(tileIndex)]
        return selectedTile
    }
    
    fileprivate func validateItemIndex(_ itemIndex:Int) -> Int {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
                if let currentView = imageViews[Order.current.rawValue] as? UIImageView,
                    let previousView = imageViews[Order.previous.rawValue] as? UIImageView,
                    let nextView = imageViews[Order.next.rawValue] as? UIImageView {
                    
                    var direction:Transition = .next
                    if (scrollView.contentOffset.x - width) < 0 {
                        //drag right
                        currentView.alpha = CGFloat(alpha)
                        previousView.alpha = 1
                        nextView.alpha = 0
                        
                        direction = .previous
                    } else {
                        //drag left
                        currentView.alpha = CGFloat(alpha)
                        previousView.alpha = 0
                        nextView.alpha = 1
                        
                        direction = .next
                    }
                    
                    if previousDirection == .unknown {
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
                if let currentTile = tileViews[Order.current.rawValue] as? SlideTileView,
                    let previousTile = tileViews[Order.previous.rawValue] as? SlideTileView,
                    let nextTile = tileViews[Order.next.rawValue] as? SlideTileView {
                    
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
    func slideScrollView(_ scrollView:SlideScrollView, didShowNextItem nextItem:Int, currentItem:Int) {
        currentPage = currentItem
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.next.rawValue] as? UIImageView {
                
                updatePreviousView(currentView)
                updateCurrentView(nextView)
                updateNextView(previousView)
                
                if let currentTile = tileAtIndex(nextItem),
                    let nextView = imageViews[Order.next.rawValue] as? UIImageView {
                    updateImage(currentTile, forView: nextView)
                }
            }
            updateVisibilityPosition()
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.previous.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.next.rawValue] as? SlideTileView,
                
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
    
    fileprivate func updatePreviousView(_ view:UIImageView) {
        imageViews.replaceObject(at: Order.previous.rawValue, with: view)
    }
    fileprivate func updateCurrentView(_ view:UIImageView) {
        imageViews.replaceObject(at: Order.current.rawValue, with: view)
    }
    fileprivate func updateNextView(_ view:UIImageView) {
        imageViews.replaceObject(at: Order.next.rawValue, with: view)
    }
    
    func slideScrollView(_ scrollView:SlideScrollView, didShowPreviousItem previousItem:Int, currentItem:Int) {
        currentPage = currentItem
        
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.next.rawValue] as? UIImageView {
                
                updatePreviousView(nextView)
                updateCurrentView(previousView)
                updateNextView(currentView)
                
                if let currentImage = tileAtIndex(previousItem),
                    let previousView = imageViews[Order.previous.rawValue] as? UIImageView {
                    updateImage(currentImage, forView: previousView)
                }
                updateVisibilityPosition()
            }
        }
        
        if tileViews.count == 3 {
            if let currentTile = tileViews[Order.current.rawValue] as? SlideTileView,
                let previousTile = tileViews[Order.next.rawValue] as? SlideTileView,
                let nextTile = tileViews[Order.previous.rawValue] as? SlideTileView,
                
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
    
    fileprivate func updateVisibilityPosition() {
        if imageViews.count == 3 {
            if let currentView = imageViews[Order.current.rawValue] as? UIImageView,
                let previousView = imageViews[Order.previous.rawValue] as? UIImageView,
                let nextView = imageViews[Order.next.rawValue] as? UIImageView {
                
                previousView.alpha = 0
                currentView.alpha = 1
                nextView.alpha = 0
                
                rootView.insertSubview(nextView, at: 0)
                rootView.insertSubview(currentView, at: 2)
                rootView.insertSubview(previousView, at: 1)
            }
        }
    }
    
}
