//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-18.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    private var imageUrls: [URL] = [] {
        didSet {
            galleryCollectionView.reloadData()
        }
    }
    
    var gallery = Gallery()
    
    private var cellSizeScale: CGFloat = 1 {
        didSet {
            galleryCollectionView.reloadData()
        }
    }
    
    var galleryDatabase = GalleryDatabase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryCollectionView.dataSource = self
         galleryCollectionView.delegate = self
         galleryCollectionView.dropDelegate = self
         galleryCollectionView.dragDelegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var galleryCollectionView: UICollectionView! {
        didSet {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleCollectionViewCells(byHandlingGestureRecognizedBy:)))
            self.galleryCollectionView.addGestureRecognizer(pinch)
        }
    }
    
    private lazy var fixedImageWidth = galleryCollectionView.bounds.width / 2
    
    @objc func scaleCollectionViewCells(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            if (cellSizeScale >= 1) {
                cellSizeScale *= recognizer.scale
                recognizer.scale = 1
            } else {
                cellSizeScale = 1
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (fixedImageWidth * cellSizeScale) > (galleryCollectionView.bounds.width / 2) {
            return CGSize(width: galleryCollectionView.bounds.width, height: galleryCollectionView.bounds.width / (gallery.images[indexPath.item].aspectRatio ))
        } else {
            return CGSize(width: fixedImageWidth * cellSizeScale, height: fixedImageWidth * (cellSizeScale / (gallery.images[indexPath.item].aspectRatio )))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageLink = gallery.images[indexPath.item].url
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let image = item.dragItem.localObject as? Image {
                    galleryCollectionView.performBatchUpdates(({
                        gallery.images.remove(at: sourceIndexPath.item)
                        gallery.images.insert(image, at: destinationIndexPath.item)
                        galleryCollectionView.deleteItems(at: [sourceIndexPath])
                        galleryCollectionView.insertItems(at: [destinationIndexPath])
                        galleryDatabase.updateGalleryInDatabase(galleryObject: gallery )
                    }))
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                var imageObject = Image(aspectRatio: 1)
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let image = provider as? UIImage {
                        DispatchQueue.main.async {
                            imageObject.aspectRatio = image.size.width / image.size.height
                        }
                    }
                }
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "ImageCell"))
                _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) {
                    (provider, error) in
                    DispatchQueue.main.async {
                        if let imageUrl = provider {
                            placeholderContext.commitInsertion(dataSourceUpdates: { [unowned self] insertionIndexPath in
                                imageObject.url = imageUrl
                                self.gallery.images.insert(imageObject, at: insertionIndexPath.item)
                                self.galleryDatabase.updateGalleryInDatabase(galleryObject: self.gallery )
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
     }
     
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: URL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        let isFromCollectionView = (session.localDragSession?.localContext as? UICollectionView) == galleryCollectionView
        
        return UICollectionViewDropProposal(operation: isFromCollectionView ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        
        if let imageUrl = (galleryCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageLink as NSURL? {
            let image = gallery.images[indexPath.item]
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: imageUrl))
            dragItem.localObject = image
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = galleryCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            self.performSegue(withIdentifier: "ImageSegue", sender: cell.image)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let image = sender as? UIImage {
            if let ivc = segue.destination as? ImageViewController {
                ivc.image = image
            }
        }
    }
    
}
