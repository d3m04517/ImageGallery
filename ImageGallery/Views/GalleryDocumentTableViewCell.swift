//
//  GalleryDocumentTableViewCell.swift
//  ImageGallery
//
//  Created by Lewis Kim on 2020-02-26.
//  Copyright © 2020 Lewis Kim. All rights reserved.
//

import UIKit

class GalleryDocumentTableViewCell: UITableViewCell, UITextFieldDelegate {

    var gallery: Gallery?
    
    var galleryDatabase: GalleryDatabase = GalleryDatabase()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.isUserInteractionEnabled = false
        // Initialization code
    }

    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            titleTextField.delegate = self
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if var cellGallery = gallery {
            if let text = textField.text {
                cellGallery.setGalleryTitle(title: text)
                galleryDatabase.updateGalleryInDatabase(galleryObject: cellGallery)
            }
        }
        textField.resignFirstResponder()
        titleTextField.isUserInteractionEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
