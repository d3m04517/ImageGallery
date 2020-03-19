//
//  Image.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-19.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import Foundation
import UIKit

struct Image: Codable, Hashable {
    
    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private var identifier: Int
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    var url: URL?
    var aspectRatio: CGFloat
    
    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
        identifier = Image.getUniqueIdentifier()
    }
    
}
