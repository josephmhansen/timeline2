//
//  PostDetailViewController.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/5/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    var post: Post?
    let postController = PostController()
    
    var comments: [Comment] = [] {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.commentTableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var followPostButtonText: UIButton!
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentsWereUpdated), name: "commentsWereUpdated", object: nil)
        guard let post = post else { return }
        updateWithPost(post)
        postController.fetchCommentsForPost(post) { 
            
        }
    }
    
    func commentsWereUpdated() {
        dispatch_async(dispatch_get_main_queue()) {
            self.commentTableView.reloadData()
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        
        guard let image = postImageView.image else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        /*
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let mailController = MFMailComposeViewController()
        
        mailController.mailComposeDelegate = self
        mailController.setSubject("Hey! Check out this cool Pic!")
        mailController.setMessageBody("\(post?.caption)", isHTML: false)
        
        if let image = postImageView.image,
            let imageData = UIImageJPEGRepresentation(image, 0.3) {
            mailController.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "\(post?.caption)")
        }
        
        presentViewController(mailController, animated: true, completion: nil)
        */
    }
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        guard let post = post else { return }
        PostController.sharedController.togglePostCommentSubscription(post) { (success, isSubscribed, error) in
            self.updateWithPost(post)
            print("follow post button tapped")
        }
        
    }
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        presentNewCommentAlert()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateWithPost(post: Post) {
        postImageView.image = post.photo
        captionLabel.text = post.caption
        timestampLabel.text = NSDate.formattedStringFromDate(post.timestamp)
        
    }
    
    func presentNewCommentAlert() {
        let alertController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .Alert)
        
        var commentTextField: UITextField?
        
        
        
        alertController.addTextFieldWithConfigurationHandler { (commentField) in
            commentField.placeholder = "Enter Comment"
            commentTextField = commentField
        }
        
        let commentAction = UIAlertAction(title: "Post", style: .Default) { (action) in
            guard let comment = commentTextField?.text where !comment.isEmpty,
            let post = self.post else {
                    self.presentErrorAlert()
                    return
            }
            self.postController.addCommentToPost(comment, post: post)
        }
        
        alertController.addAction(commentAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Oh no", message: "Possible network connectivity issues, please try again.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row+1 == postController.posts.count {
            postController.fetchPosts({ (newComments) in
                
            })
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let post = post else { return  UITableViewCell() }
            let comment = post.comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = NSDate.formattedStringFromDate(comment.timestamp)
        cell.imageView?.contentMode = .ScaleAspectFill
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return Int() }
        return post.comments.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
