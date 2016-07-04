//
//  Post.swift
//  Makestagram
//
//  Created by Ahmed Abdelrahman on 6/30/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class Post: PFObject, PFSubclassing { // need to inherit from those classes to create a custom class for Parse
    
    // properties of our class. @NSManaged means Parse will take care of initializing the values
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: UIImage? // stores the image
    var photoUploadTask: UIBackgroundTaskIdentifier? // used to request long running background task

    //MARK: PFSubclassing Protocol
    
    // Creates a connection between Parse and the Swift class
    static func parseClassName() -> String {
        return "Post"
    }
    
    // boilerplate code
    override init () {
        super.init()
    }
    
    // boilerplate code
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return } // convert JPEG to NSData
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else { return } // convert NSData to PFFile
            
            // any uploaded post should be associated with the current user
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }}
