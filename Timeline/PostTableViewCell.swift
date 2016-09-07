//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/7/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func updateWithPost(post: Post) {
        postImage.image = post.photo
        timestampLabel.text = NSDate.formattedStringFromDate(post.timestamp)
        captionLabel.text = post.caption
    }

}


extension NSDate {
   static func formattedStringFromDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }
}
