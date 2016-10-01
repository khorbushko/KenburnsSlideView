//
//  ScalablePageControl.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

enum Transition:Int {
    case Unknown = -1
    case Next = 0
    case Previous = 1
}

final class ScalablePageControl : BaseView {
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var itemsCount:Int = 10 {
        didSet {
            collectionVIew.reloadData()
        }
    }
    
    var pageControlCells:[ScalablePageControlCollectionViewCell] = []
    
    var startPage:Int = 0
    
    var selectedPage:Int = 0 {
        didSet {
            var fromItem = selectedPage
            if fromItem < 0 {
                fromItem = itemsCount - (abs(fromItem) % itemsCount)
            }
            let item = fromItem % itemsCount
            
            for (index, cell) in pageControlCells.enumerate() {
                if index == item {
                    cell.isSelectedPage = true
                } else {
                    cell.isSelectedPage = false
                }
            }
        }
    }
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionVIew.registerNib(ScalablePageControlCollectionViewCell.nib(), forCellWithReuseIdentifier: ScalablePageControlCollectionViewCell.identifier())
    }
    
    // MARK: - Public
    
    func updateItem(itemIndex:Int, withTransition:Transition, withCurrentPorgress:CGFloat) {
        
        var fromItem = itemIndex
        if fromItem < 0 {
            fromItem = itemsCount - (abs(fromItem) % itemsCount)
        }
        
        let fromItemIndex = fromItem % itemsCount
        
        var toItemIndex = fromItemIndex
        if withTransition == .Next {
            toItemIndex += 1
        } else if withTransition == .Previous {
            toItemIndex -= 1
        }
        
        if toItemIndex > itemsCount - 1 {
            toItemIndex = 0
        } else if toItemIndex < 0 {
            toItemIndex = itemsCount - 1
        }

        let fromCell = pageControlCells[fromItemIndex]
        let toCell = pageControlCells[toItemIndex]
        
        let currentItemProgress = 1 - withCurrentPorgress
        let nextItemProgress = withCurrentPorgress

        fromCell.applyTransformWithProgress(currentItemProgress)
        toCell.applyTransformWithProgress(nextItemProgress)
        
    }
}

extension ScalablePageControl : UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ScalablePageControlCollectionViewCell.identifier(), forIndexPath: indexPath) as! ScalablePageControlCollectionViewCell
        pageControlCells.append(cell)
        if indexPath.row == selectedPage {
            cell.isSelectedPage = true
        }
        return cell
    }
}

extension ScalablePageControl: UICollectionViewDelegate {
    // MARK: - UICollectionViewDelegate
    
    
}

extension ScalablePageControl : UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height:CGFloat = collectionView.frame.height
        let width:CGFloat = 15
        
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let insets = (bounds.width - CGFloat(itemsCount * 15)) / 2
        return UIEdgeInsetsMake(0, insets, 0, insets)
    }
}