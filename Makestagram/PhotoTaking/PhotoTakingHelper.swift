//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Ahmed Abdelrahman on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void // callback function receives UIImage and returns nothing

class PhotoTakingHelper : NSObject {
    
    weak var viewController: UIViewController! // View controller on which AlertViewController and UIImagePickerController are presented. Weak reference since it doesn't own the referenced viewController
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        super.init()
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection() {
        
        // Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        // Add cancel option to the UIAlertAction
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                self.showImagePickerController(.Camera)  // triggered if camera option was picked
            }
            alertController.addAction(cameraAction)
        }
        
        // Add photo library option to the UIAlertAction
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
            self.showImagePickerController(.PhotoLibrary) // triggered if photo library option was picked
        }
        alertController.addAction(photoLibraryAction)
        
        // Present the alert controller on the view controller that was passed
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType // sourceType is either camera or photo library
        imagePickerController!.delegate = self
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil) // presents the ImagePickerController to the user
    }
    
}

// This extension allows the PhotoTakingHelper to control the behavior once the UIImagePickerController is displayed
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This method is called if user finished picking an image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        viewController.dismissViewControllerAnimated(false, completion: nil) // dismiss the UIViewController
        callback(image) // provides the image to the callback function
    }
    
    // This method is called if cancel was pressed
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}