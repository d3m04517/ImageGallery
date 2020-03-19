//
//  Gallery.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-19.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import Foundation
import UIKit

struct Gallery: Codable, Hashable {
    
    static func == (lhs: Gallery, rhs: Gallery) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var identifier: String
    private static var identifierFactory = 0
    
    var images = [Image]()
    private var galleryTitle = ""
    
    mutating func setGalleryTitle(title: String) {
        galleryTitle = title
    }
    
    private static func getUniqueIdentifier() -> String {
        return UUID().uuidString
    }
    
    func getGalleryTitle() -> String {
        return galleryTitle
    }
    
    init() {
        identifier = Gallery.getUniqueIdentifier()
    }
    
 }
