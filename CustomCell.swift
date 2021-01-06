//
//  CollectionViewCell.swift
//  MicrosoftAssignment
//
//  Created by Talha Khalid on 12/24/20.
//  Copyright © 2020 TalhaKhalid. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    //@IBOutlet var imageView: UIImageView!
    
    var myImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        myImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(myImageView)
        myImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        myImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        myImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
}
