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
            //доб появление меню для выбора фото new place
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
