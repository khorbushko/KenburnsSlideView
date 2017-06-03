//
//  SlideTileObject.swift
//  
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

final class SlideTileObject {
    
    var image:UIImage?
    var title:String?
    var subtitle:String?
    var imageURL:URL?
    
   // MARK: - LifeCycle
    
    convenience init(image:UIImage?, title:String?, subtitle:String?, imageURL:URL?) {
        self.init()
        
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
    
    init() {
        
    }
}
