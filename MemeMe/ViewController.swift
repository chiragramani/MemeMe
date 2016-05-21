//
//  ViewController.swift
//  MemeMe
//
//  Created by Chirag Ramani on 21/05/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    struct MemedObject{
        let topText:String
        let bottomtext:String
        let imageOnly:UIImage
        let memedImage:UIImage
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 0.0
        ]
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text="TOP"
        bottomTextField.text="BOTTOM"
        topTextField.textAlignment=NSTextAlignment.Center
        bottomTextField.textAlignment=NSTextAlignment.Center
        topTextField.delegate=self
        bottomTextField.delegate=self
        shareButton.enabled=false
        
        
    }
    
    
    @IBAction func cameraButton(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert:UIAlertController = UIAlertController(title:"Camera Unavailable",message: "This device does not have camera support",preferredStyle: UIAlertControllerStyle.Alert)
            let okAction=UIAlertAction(title:"Ok",style: UIAlertActionStyle.Default,handler: {
                action in self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage:UIImage=info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode=UIViewContentMode.ScaleAspectFit
        imageView.image=selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        shareButton.enabled=true
        
    }
    
    @IBAction func albumButton(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func shareActivity(sender: UIBarButtonItem) {
        
        let meme=MemedObject(topText: topTextField.text!, bottomtext: bottomTextField.text!, imageOnly: imageView.image!, memedImage: generateMemedImage())
        let shareAction=UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        presentViewController(shareAction, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelActivity(sender: AnyObject) {
        shareButton.enabled=false
        imageView.image=nil
        topTextField.text="TOP"
        bottomTextField.text="BOTTOM"
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text=""
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.subscribeToKeyboardNotifications()
        
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if (bottomTextField.editing)
        {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(bottomTextField.editing)
        {
            self.view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    func generateMemedImage() -> UIImage {
        self.bottomToolbar.hidden=true
        self.topToolbar.hidden=true
        // self.navigationController?.setToolbarHidden(true, animated: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.bottomToolbar.hidden=false
        self.topToolbar.hidden=false
        // self.navigationController?.setToolbarHidden(false, animated: true)
        
        return memedImage
    }
    
    
    
    
    
    
    
    
}

