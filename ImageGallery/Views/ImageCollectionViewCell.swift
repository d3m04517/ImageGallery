//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-19.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var aspectRatio: CGFloat = 1.0
    
    var image = UIImage() {
        didSet {
            self.imageView.image = image
            activityIndicator.isHidden = true
        }
    }
    
    var imageLink: URL? {
        didSet {
            if let imageUrl = imageLink {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let urlContents = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            if let tempImage = UIImage(data: urlContents) {
                                self.image = tempImage
                            }
                        }
                    }
                }
            }
        }
    }
    
}
