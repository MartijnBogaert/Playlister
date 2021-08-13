//
//  PlaylistCollectionViewCell.swift
//  Playlister
//
//  Created by Martijn Bogaert on 04/08/2021.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        // Make background 'light up' when playlist is touched
        let background = UIView(frame: bounds)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.75)
        
        selectedBackgroundView = background
        
        NSLayoutConstraint.activate(
            [leadingAnchor.constraint(equalTo: background.leadingAnchor),
             trailingAnchor.constraint(equalTo: background.trailingAnchor),
             topAnchor.constraint(equalTo: background.topAnchor),
             bottomAnchor.constraint(equalTo: background.bottomAnchor)]
        )
    }
}
