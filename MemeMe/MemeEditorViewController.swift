//
//  ViewController.swift
//  MemeMe
//
//  Created by Chirag Ramani on 21/05/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit



class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.4        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldAttributes(topTextField)
        setTextFieldAttributes(bottomTextField)
        shareButton.enabled=false
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        
    }
    func setTextFieldAttributes(textField:UITextField)->Void
    {
        textField.defaultTextAttributes=memeTextAttributes
        textField.textAlignment=NSTextAlignment.Center
        textField.delegate=self
        textField.text=(textField.tag==0) ? "TOP" : "BOTTOM"
    }
    
    
    @IBAction func cameraButton(sender: AnyObject) {
        
        
        setImagePickerController("Camera")
    }
    func setImagePickerController(source:String)->Void
    {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType=(source=="Camera") ? UIImagePickerControllerSourceType.Camera : UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage:UIImage=info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode=UIViewContentMode.ScaleAspectFit
        imageView.image=selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        shareButton.enabled=true
        
    }
    
    @IBAction func albumButton(sender: AnyObject) {
        
        setImagePickerController("Album")
        
    }
    @IBAction func shareActivity(sender: UIBarButtonItem) {
        
        let img:UIImage=generateMemedImage()
        
        let shareAction=UIActivityViewController(activityItems: [img], applicationActivities: nil)
        presentViewController(shareAction, animated: true, completion: { ()->Void in
            MemedObject.MemedObj(topText: self.topTextField.text!, bottomtext: self.bottomTextField.text!, imageOnly: self.imageView.image!, memedImage: img)
            
        })
    }
    
    
    @IBAction func cancelActivity(sender: AnyObject) {
        shareButton.enabled=false
        imageView.image=nil
        topTextField.text="TOP"
        bottomTextField.text="BOTTOM"
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text=="TOP" || textField.text=="BOTTOM")
        {
            textField.text=""
        }
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
            self.view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(bottomTextField.editing)
        {
            self.view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:))   , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.bottomToolbar.hidden=false
        self.topToolbar.hidden=false
        
        return memedImage
    }
    override func prefersStatusBarHidden() -> Bool {
        return true   
    }
}

