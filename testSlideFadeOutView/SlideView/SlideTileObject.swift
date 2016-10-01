//
//  SlideTileObject.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

final class SlideTileObject {
    
    var image:UIImage?
    var title:String?
    var subtitle:String?
    var imageURL:NSURL?
    
   // MARK: - LifeCycle
    
    convenience init(image:UIImage?, title:String?, subtitle:String?, imageURL:NSURL?) {
        self.init()
        
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
    
    init() {
        
    }
}
