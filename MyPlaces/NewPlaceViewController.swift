//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 04.12.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        // отслеживание поля Name, для Save button
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
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
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController
        else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
        
    }
    
    
    func savePlace() {
        //        var image: UIImage?
        //        if imageIsChanged {
        //            image = placeImage.image
        //        } else {
        //            image = #imageLiteral(resourceName: "imagePlaceholder")
        //        }
        let image: UIImage? = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            })
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    // при редактировании записи нашего объекта
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigatioBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            // масштабирование image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
        
    }
    
    private func setupNavigatioBar() {
        // изменим title кнопки возврата
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
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

extension NewPlaceViewController: MapViewContollerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}

