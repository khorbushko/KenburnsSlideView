//
//  ScalablePageControl.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

enum Transition:Int {
    case unknown = -1
    case next = 0
    case previous = 1
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
            
            for (index, cell) in pageControlCells.enumerated() {
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
        
        collectionVIew.register(ScalablePageControlCollectionViewCell.nib(), forCellWithReuseIdentifier: ScalablePageControlCollectionViewCell.identifier())
    }
    
    // MARK: - Public
    
    func updateItem(_ itemIndex:Int, withTransition:Transition, withCurrentPorgress:CGFloat) {
        
        var fromItem = itemIndex
        if fromItem < 0 {
            fromItem = itemsCount - (abs(fromItem) % itemsCount)
        }
        
        let fromItemIndex = fromItem % itemsCount
        
        var toItemIndex = fromItemIndex
        if withTransition == .next {
            toItemIndex += 1
        } else if withTransition == .previous {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScalablePageControlCollectionViewCell.identifier(), for: indexPath) as! ScalablePageControlCollectionViewCell
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height:CGFloat = collectionView.frame.height
        let width:CGFloat = 15
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = (bounds.width - CGFloat(itemsCount * 15)) / 2
        return UIEdgeInsetsMake(0, insets, 0, insets)
    }
}
