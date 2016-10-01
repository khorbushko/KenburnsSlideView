//
//  ViewController.swift
//  testSlideFadeOutView
//
//  Created by Kirill Gorbushko on 30.09.16.
//  Copyright © 2016 - present SigmaSoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slideView: SlideView!
    @IBOutlet weak var pageControl: ScalablePageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = [
            UIImage(named: "imgHair1.jpg")!,
            UIImage(named: "imgHair2.jpg")!,
            UIImage(named: "imgHair3.jpg")!,
            UIImage(named: "imgHair5.jpg")!
        ]
        
        var obj:[SlideTileObject] = []
        for item in 0..<4 {
            let tileObject = SlideTileObject(image: img[item], title: "Item \(item)", subtitle: "Subtitle", imageURL: nil)
            obj.append(tileObject)
        }

        if let url = NSURL(string: "https://3.bp.blogspot.com/-W__wiaHUjwI/Vt3Grd8df0I/AAAAAAAAA78/7xqUNj8ujtY/s1600/image02.png") {
            let tileObject = SlideTileObject(image: nil, title: "Item \(url)", subtitle: "Subtitle", imageURL: url)
            obj.append(tileObject)
        }
        

        slideView.imagesData = obj
        slideView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SlideViewDelegate {
    // MARK: - SlideViewDelegate
    func slideView(slideView: SlideView, downloadImageURL: NSURL, completion: ((image: UIImage) -> Void)) {
        dispatch_async(dispatch_get_main_queue(), {
            if let data = NSData(contentsOfURL: downloadImageURL) {
                if let imageFromData = UIImage(data: data) {
                    completion(image: imageFromData)
                }
            }
        })
    }
    
    func slideView(slideView:SlideView, didScrollToProgress:CGFloat, transition:Transition, currentPage:Int) {
        print("scrollFrom - \(currentPage) to " + (transition == .Next ? "\(currentPage + 1)" : "\(currentPage - 1)"))
        pageControl.updateItem(currentPage, withTransition: transition, withCurrentPorgress: didScrollToProgress)
    }
    
    func slideView(slideView:SlideView, didShowItem displayItem:Int) {
        print("SHOW - \(displayItem)")
        pageControl.selectedPage = displayItem
    }

    
//    func slideView(slideView:SlideView, didScrollToProgress:CGFloat, leftScroll:Bool, currentPage:Int) {
////        print("\(didScrollToProgress)")
//        
////        pageControl.progress = didScrollToProgress
//        
//        pageControl.updateItem(currentPage, withTransition: leftScroll == true ? .Previous : .Next , withCurrentPorgress: didScrollToProgress)
//    }
//    
//    func slideView(slideView: SlideView, didEndScrolling currentPage: Int) {
//        pageControl.selectedPage = currentPage
//    }
}

