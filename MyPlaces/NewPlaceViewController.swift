//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 04.12.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //добавим меню для выбора фото new place
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(sourse: .camera)
            }
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(cancel)
            actionSheet.addAction(photo)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    
}
// MARK: - Table view delegate
extension NewPlaceViewController: UITextFieldDelegate {
    // скрывает клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // скрываем клавиатуру по тапу на ячейку
}

// MARK: - Work with image
extension NewPlaceViewController {
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
            
        }
    }
}
