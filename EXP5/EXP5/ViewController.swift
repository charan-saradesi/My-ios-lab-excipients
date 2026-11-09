// ViewController.swift
// ImagePickerDemo
//
// Created by shiro on 13/03/26.
//
import UIKit

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate {  // ← "Navigaton" → "Navigation"
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.  // ← "additonal", "ater" fixed
    }
    
    @IBAction func addImagePress(_ sender: Any) {  // ← "IBActon" → "IBAction"
        let ac = UIAlertController(title: "Select Image",  // ← "ttle" → "title"
                                   message: "Select image from Camera or Gallery",
                                   preferredStyle: .actionSheet)  // ← "actonSheet" → "actionSheet"
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) { [weak self] (_) in  // ← "UIAlertActon", "ttle"
            self?.showImagePicker(selectedSource: .camera)
        }
        let libraryBtn = UIAlertAction(title: "Library", style: .default) { [weak self] (_) in
            self?.showImagePicker(selectedSource: .photoLibrary)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)  // ← .default → .cancel (better UX)
        
        ac.addAction(cameraBtn)    // ← "addActon" → "addAction"
        ac.addAction(libraryBtn)
        ac.addAction(cancelBtn)
        
        self.present(ac, animated: true, completion: nil)  // ← "completon" → "completion"
    }
    
    func showImagePicker(selectedSource: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else {
            print("Selected Source type is not available")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false  // ← "allowsEditng" → "allowsEditing"
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {  // ← removed stray space in info[
            imgView.image = selectedImage
        } else {
            print("Image not found")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
