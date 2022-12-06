//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 04.12.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    var newPlace = Place()
    var imageIsChanged = false
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
        saveButton.isEnabled = false

        
        // отслеживание поля Name, для Save button
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            // #imageLiteral(resourceName: "camera")
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon =  #imageLiteral(resourceName: "photo")
            
            //добавим меню для выбора фото new place
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(cancel)
            actionSheet.addAction(photo)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
        
    }
    
    func saveNewPlace() {
        var image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
//        newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, image: image, restaurantImage: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}
// MARK: - Table view delegate
extension NewPlaceViewController: UITextFieldDelegate {
    // скрывает клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            // данны й объект будет делегировать обязанности
            // по выполнению метода imagePickerController
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        // масштабируем изображение по UIImage
        placeImage.contentMode = .scaleAspectFill
        // обрезка по границе изображения
        placeImage.clipsToBounds = true
        imageIsChanged = true
        // закрывает данный метод
        dismiss(animated: true)
    }
}


