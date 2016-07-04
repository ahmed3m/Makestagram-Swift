//
//  Post.swift
//  Makestagram
//
//  Created by Ahmed Abdelrahman on 6/30/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post: PFObject, PFSubclassing { // need to inherit from those classes to create a custom class for Parse
    
    // properties of our class. @NSManaged means Parse will take care of initializing the values
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: Observable<UIImage?> = Observable(nil)
    var likes: Observable<[PFUser]?> = Observable(nil)
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
        if let image = image.value {
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
    }
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        if (likes.value != nil) {
            return
        }
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            // if post is liked, unlike it now
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post: self)
        } else {
            // if this post is not liked yet, like it now
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
}
