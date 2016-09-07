//
//  Post.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/6/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post {
    
    
    
    
    
    let photoData: NSData?
    let caption: String
    let timestamp: NSDate
    var comments: [Comment]
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    var cloudKitRecordID: CKRecordID?
    
    var recordType: String { return Post.recordType }
    
    init(photoData: NSData?, caption: String, timestamp: NSDate = NSDate(), comments: [Comment] = []) {
        self.timestamp = timestamp
        self.caption = caption
        self.photoData = photoData
        self.comments = comments
    }
    
    convenience init?(record: CKRecord) {
        guard let timestamp = record[Post.kTimestamp] as? NSDate,
        photoAsset = record[Post.kPhotoData] as? CKAsset,
        caption = record[Post.kCaption] as? String,
        photoData = NSData(contentsOfURL: photoAsset.fileURL)
            else { return nil }
        
        self.init(photoData: photoData, caption: caption, timestamp: timestamp)
        
    }
    
    private var temporaryPhotoURL: NSURL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        
        photoData?.writeToURL(fileURL, atomically: true)
        return fileURL
    }
    
}

extension Post {
    static var recordType: String  { return "Post" }
    static var kPhotoData = "photoData"
    static var kTimestamp = "timestamp"
    static var kCaption = "caption"
    
    
}

extension CKRecord {
    convenience init(_ post: Post) {
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        self.init(recordType: post.recordType, recordID: recordID)
        
        self[Post.kTimestamp] = post.timestamp
        self[Post.kCaption] = post.caption
        self[Post.kPhotoData] = CKAsset(fileURL: post.temporaryPhotoURL)
    }
}