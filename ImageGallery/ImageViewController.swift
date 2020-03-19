//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-28.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.delegate = self
        if let galleryImage = image {
            imageView.image = galleryImage
        }
        imageView.sizeToFit()
        imageScrollView.contentSize = imageView.frame.size
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var imageScrollView: UIScrollView! {
        didSet {
            imageScrollView.addSubview(imageView)
            imageScrollView.maximumZoomScale = 1.0
            imageScrollView.minimumZoomScale = 1/2
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    var imageView = UIImageView()
    
    var image: UIImage?   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
