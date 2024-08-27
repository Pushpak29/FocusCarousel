//
//  ViewController.swift
//  Atlys
//
//  Created by Pushpak Athawale on 24/08/24.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let images = [
            UIImage(named: "image_1")!,
            UIImage(named: "image_2")!,
            UIImage(named: "image_3")!
        ]
        
        let carousel = CarouselView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 300), images: images)
        view.addSubview(carousel)
    }
}

