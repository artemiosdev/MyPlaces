//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 28.11.2022.
//

import UIKit

class MainViewController: UITableViewController {
    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        // Configure content.
//      content.image = UIImage(systemName: restaurantNames[indexPath.row])
        content.text = restaurantNames[indexPath.row]
        content.image = UIImage(named: restaurantNames[indexPath.row])

        // Customize appearance.
        cell.contentConfiguration = content
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
