//
//  DropdownButton.swift
//  Legan
//
//  Created by Mohamed Elkassas on 9/10/19.
//  Copyright © 2019 Legan. All rights reserved.
//

import UIKit
import DropDown

@IBDesignable
class DropdownButton: UIButton {
    
    var selectionClosure: SelectionClosure?
    
    var dropDownMenu = DropDown()
    
    var optionsData: [String]? {
        didSet {
            dropDownMenu.dataSource = optionsData!
        }
    }
    
    @IBInspectable var rightIcon: UIImage? {
        didSet {
            let icon = UIImageView(image: rightIcon)
            icon.contentMode = .scaleAspectFit
            addSubview(icon)
            icon.translatesAutoresizingMaskIntoConstraints = false
            let verticalConstraint = icon.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            icon.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant:0).isActive = true
            NSLayoutConstraint.activate([verticalConstraint])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        layer.cornerRadius = 5
        self.clipsToBounds = true
        
//        layer.borderColor = UIColor.lightGray.cgColor
//        layer.borderWidth = 0.3
        
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
//        titleLabel?.font = Constants.applicationBoldFont(ofSize: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
        
        contentHorizontalAlignment = .left
        
        let arrow = UIImageView(image: UIImage(named: "downArrow"))
        arrow.contentMode = .scaleAspectFit
        addSubview(arrow)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        let verticalConstraint = arrow.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        arrow.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        NSLayoutConstraint.activate([verticalConstraint])
        
        dropDownMenu.anchorView = self
        
        addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        // Action triggered on selection
        dropDownMenu.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.setTitle(item, for: .normal)
            self.selectionClosure?(index,item)
        }
    }
    
    @IBAction func buttonAction(_ sender: DropdownButton) {
        sender.dropDownMenu.show()
    }
}
