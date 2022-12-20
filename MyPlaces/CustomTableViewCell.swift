//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 01.12.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        // отключим возможность изменения кол-ва звезд на главном MainViewController
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
}
