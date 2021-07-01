//
//  DemoViewController.swift
//  StretchyHeaderViewController
//
//  Created by Frédéric Quenneville on 18-01-04.
//  Copyright © 2018 Frédéric Quenneville. All rights reserved.
//

import Foundation
import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var minHeightTextInput: UITextField!
    @IBOutlet weak var maxHeightTextInput: UITextField!
    @IBOutlet weak var changeTintColorButton: UIButton!
    @IBOutlet weak var showControllerButton: UIButton!
    
    fileprivate var stretchyHeaderViewController = StretchyHeaderViewController()
    
    fileprivate lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DemoViewController.dismissKeyboard))
        scrollView.addGestureRecognizer(tap)
        
        stretchyHeaderViewController.scrollView = tableView
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func didTapUploadImageButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeFromCamera = UIAlertAction.init(title: "Take a picture", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraDevice = .rear
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let takeFromLibrary = UIAlertAction.init(title: "Choose a picture", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        
        alertController.addAction(takeFromCamera)
        alertController.addAction(takeFromLibrary)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = imageView.frame
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didTapTintButton(_ sender: Any) {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        changeTintColorButton.tintColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    @IBAction func didTapShowViewController(_ sender: Any) {
        stretchyHeaderViewController.headerTitle = titleTextField.text ?? ""
        stretchyHeaderViewController.headerSubtitle = subtitleTextField.text ?? ""
        stretchyHeaderViewController.image = imageView.image
        
        if let minHeight = NumberFormatter().number(from: minHeightTextInput.text ?? "") {
            stretchyHeaderViewController.minHeaderHeight = CGFloat(truncating: minHeight)
        } else {
            stretchyHeaderViewController.minHeaderHeight = 0.0
        }
        
        if let maxHeight = NumberFormatter().number(from: maxHeightTextInput.text ?? "") {
            stretchyHeaderViewController.maxHeaderHeight = CGFloat(truncating: maxHeight)
        } else {
            stretchyHeaderViewController.maxHeaderHeight = 0.0
        }
        
        stretchyHeaderViewController.tintColor = changeTintColorButton.tintColor
        
        self.present(stretchyHeaderViewController, animated: true, completion: nil)
    }
}

extension DemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension DemoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchyHeaderViewController.updateHeaderView()
    }
}
