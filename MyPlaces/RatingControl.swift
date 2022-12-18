//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 18.12.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    // MARK: Properties
    private var ratingButtons = [UIButton]()
    var rating = 0
    
    // добавим свойства, для отображения в Interface Builder
    @IBInspectable var starsSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starsCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    // MARK: Initialization
    // для добавления элементов в view кодом
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    // для storyboard
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    @objc func ratingButtonPressed() {
        print("Button Pressed")
    }
    
    // MARK: Private methods
    private func setupButtons() {
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        
        for _ in 1...starsCount {
            // Create the button
            let button = UIButton()
            button.backgroundColor = .red
            
            // Add constraints
            // отключает автоматически сгенерированные constraints для кнопки
            // по умолчанию они true, и ниже мы из заменяем собственными
            button.translatesAutoresizingMaskIntoConstraints = false
            // constraints высоты и ширины кнопки, их активация
            button.heightAnchor.constraint(equalToConstant: starsSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starsSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonPressed), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the button in the rating button array
            ratingButtons.append(button)
        }
    }
}
