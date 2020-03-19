//
//  GalleryDatabase.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-24.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import Foundation

class GalleryDatabase {
    
    private(set) var galleries: [Gallery] {
        didSet {
            storeGalleriesInDatabase(galleries, at: "galleries")
        }
    }
    
    private(set) var recentlyDeleted: [Gallery] {
        didSet {
            storeGalleriesInDatabase(recentlyDeleted, at: "recentlyDeleted")
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        galleries = []
        recentlyDeleted = []
        
        if let allGalleries = getGalleriesInDatabase(at: "galleries") {
            galleries = allGalleries
        }
        if let recentlyDeletedGalleries = getGalleriesInDatabase(at: "recentlyDeleted") {
            recentlyDeleted = recentlyDeletedGalleries
        }
        
    }
    
    func getGalleriesInDatabase(at key: String) -> [Gallery]? {
        if let galleriesData = userDefaults.value(forKey: key) as? Data {
            if let allGalleries = try? JSONDecoder().decode([Gallery].self, from: galleriesData) {
                return allGalleries
            }
        }
        return nil
    }
    
    private func storeGalleriesInDatabase(_ allGalleries: [Gallery], at key: String) {
        do {
            userDefaults.setValue(try? JSONEncoder().encode(allGalleries), forKey: key)
        }
        userDefaults.synchronize()
    }
    
    func updateGalleryInDatabase(galleryObject gallery: Gallery) {
        recentlyDeleted = getGalleriesInDatabase(at: "recentlyDeleted") ?? []
        galleries = getGalleriesInDatabase(at: "galleries") ?? []
        if let galleryIndex = galleries.firstIndex(of: gallery) {
            galleries[galleryIndex] = gallery
            storeGalleriesInDatabase(galleries, at: "galleries")
        }
        if let galleryIndex = recentlyDeleted.firstIndex(of: gallery) {
            recentlyDeleted[galleryIndex] = gallery
            storeGalleriesInDatabase(recentlyDeleted, at: "recentlyDeleted")
        }
    }
    
    func removeGalleryInDatabase(galleryObject gallery: Gallery) {
        galleries = getGalleriesInDatabase(at: "galleries") ?? []
        if let galleryIndex = galleries.firstIndex(of: gallery) {
            let removedGallery = galleries.remove(at: galleryIndex)
            recentlyDeleted += [removedGallery]
        }
    }
    
    func removeRecentlyDeletedInDatabase(galleryObject gallery: Gallery) {
        if let galleryIndex = recentlyDeleted.firstIndex(of: gallery) {
            recentlyDeleted.remove(at: galleryIndex)
        }
    }
    
    func undeleteGalleryInDatabase(galleryObject gallery: Gallery) {
        recentlyDeleted = getGalleriesInDatabase(at: "recentlyDeleted") ?? []
        if let galleryIndex = recentlyDeleted.firstIndex(of: gallery) {
            let undeletedGallery = recentlyDeleted.remove(at: galleryIndex)
            galleries += [undeletedGallery]
        }
    }
    
    func addGallery(_ gallery: Gallery) {
        galleries = getGalleriesInDatabase(at: "galleries") ?? []
        galleries += [gallery]
    }
    
}
