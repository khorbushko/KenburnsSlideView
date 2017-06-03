//
//  BaseCollectionViewCell.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    class func identifier() -> String {
        return String(describing: self)
    }
    
    class func nib() -> UINib {
        return UINib.init(nibName: self.identifier(), bundle:nil)
    }
}

