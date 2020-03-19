//
//  GalleryDocumentTableViewController.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-20.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import UIKit

class GalleryDocumentTableViewController: UITableViewController {
    
    private var galleries = [Gallery]()
    
    private var recentlyDeleted = [Gallery]()
    
    var galleryDatabase: GalleryDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryDatabase = GalleryDatabase()
        updateGalleries()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    @IBAction func addDocument(_ sender: Any) {
        var gallery = Gallery()
        gallery.setGalleryTitle(title: "Untitled \(galleries.count)")
        galleryDatabase?.addGallery(gallery)
        updateGalleries()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return galleries.count
        case 1:
            return recentlyDeleted.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTapGesture.numberOfTapsRequired = 2
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! GalleryDocumentTableViewCell
        var gallery = indexPath.section == 0 ? galleries[indexPath.row] : recentlyDeleted[indexPath.row]
        cell.gallery = gallery
        if gallery.getGalleryTitle().isEmpty, indexPath.section == 0 {
            gallery.setGalleryTitle(title: "Untitled \(indexPath.row)")
            cell.titleTextField.text = gallery.getGalleryTitle()
            galleryDatabase?.updateGalleryInDatabase(galleryObject: gallery)
        } else {
            cell.titleTextField.text = gallery.getGalleryTitle()
        }
        cell.addGestureRecognizer(doubleTapGesture)
        return cell
    }
    
    @objc func doubleTapAction(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: indexPath) as? GalleryDocumentTableViewCell {
                    tappedCell.titleTextField.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            self.performSegue(withIdentifier: "imageDetails", sender: cell)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        updateGalleries()
        if editingStyle == .delete, indexPath.section == 0 {
            galleryDatabase?.removeGalleryInDatabase(galleryObject: galleries[indexPath.row])
            updateGalleries()
            self.tableView.reloadData()
        } else if editingStyle == .delete, indexPath.section == 1 {
            galleryDatabase?.removeRecentlyDeletedInDatabase(galleryObject: recentlyDeleted[indexPath.row])
            updateGalleries()
            self.tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextualAction = UIContextualAction(style: .normal, title: "Undelete", handler: { (action,view,completionHandler) in
            self.galleryDatabase?.undeleteGalleryInDatabase(galleryObject: self.recentlyDeleted[indexPath.row])
            self.updateGalleries()
            completionHandler(true)
            self.tableView.reloadData()
        })
        let configuration = UISwipeActionsConfiguration(actions: [contextualAction])
        return indexPath.section == 1 ? configuration : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("Recently Deleted", comment: "recentlyDeleted")
        default:
            return ""
        }
    }
    
    private func updateGalleries() {
        galleries = galleryDatabase?.getGalleriesInDatabase(at: "galleries") ?? []
        recentlyDeleted = galleryDatabase?.getGalleriesInDatabase(at: "recentlyDeleted") ?? []
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedCell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: selectedCell) {
                if let nvc = segue.destination as? UINavigationController {
                    if let imvc = nvc.topViewController as? ImageGalleryViewController{
                        updateGalleries()
                        imvc.gallery = galleries[indexPath.row]
                    }
                }
            }
        }
    }
    
}
