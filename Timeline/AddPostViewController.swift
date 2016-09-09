//
//  AddPostViewController.swift
//  Timeline
//
//  Created by Joseph Hansen on 9/5/16.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate {
    
    var post: Post?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        
        
    }
    @IBAction func postButtonTapped(sender: AnyObject) {
        guard let image = self.postImageView.image,
        caption = self.captionTextField.text,
        imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        
        
            let post = Post(photoData: imageData, caption: caption, timestamp: NSDate(), comments: [])
            PostController.sharedController.createPost(post)
            self.post = post
        let comment = Comment(post: post, text: caption)
        PostController.sharedController.addCommentToPost(comment.text, post: post)
    
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func addPhotoButtonTapped(sender: AnyObject) {
        
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Choose an image", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default) { (_) in
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default) { (_) in
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let savedPhotoAlbum = UIAlertAction(title: "Saved Photos", style: .Default) { (_) in
            imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        actionSheet.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            actionSheet.addAction(photoLibraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            actionSheet.addAction(savedPhotoAlbum)
        }
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        addPhotoButton.setTitle("", forState: .Normal)
        postImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.size.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
            
            scrollView.scrollRectToVisible((captionTextField.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
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
