//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Ahmed Abdelrahman on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper? // need an instance of the PhotoTakingHelper class
    @IBOutlet weak var tableView: UITableView!
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self  // setting the TimelineViewController as the delegate for the tabBarController
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ParseHelper.timelineRequestForCurrentUser {
            (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []  // if result is nill, we have empty array/no posts
            for post in self.posts {  // looping through the posts
                do {
                    let data = try post.imageFile?.getData()  // downloading the NSData of the image
                    post.image = UIImage(data: data!, scale:1.0)  // converting from NSData to UIImage
                } catch {
                    print("could not get image")
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            post.image = image
            post.uploadPost()
        }
    }
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    // This method is called when the user presses on an item in the tab bar
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {    // Used "is" to check if it's of the same type/class
            takePhoto()
            return false  // returning false results in not displaying the PhotoViewController
        } else {
            return true
        }
    }
}

// MARK: Table View Data Source

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        cell.postImageView.image = posts[indexPath.row].image
        return cell
    }
}