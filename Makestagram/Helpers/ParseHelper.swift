//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Ahmed Abdelrahman on 7/4/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        
        // this query grabs users that the current user is following
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        
        // this query grabs the posts of the followers that the current user is following
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        
        // this query grabs the posts that the current user has posted
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        // puts the results from both queries together
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        
        query.includeKey("user") // downloads the content of the user instead of the pointer
        query.orderByDescending("createdAt") // newest post at the top
        
        // kicking off the network request
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
}