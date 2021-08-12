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
    @IBOutlet weak var separatorLineView: UIView?
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        // MARK: Make playlist cover have rounded corners
        coverImageView.layer.cornerRadius = 5
        coverImageView.clipsToBounds = true
        
        // MARK: Set height of separator line to 1 pixel
        separatorLineHeightConstraint?.constant = 1 / UITraitCollection.current.displayScale
        
        // MARK: Make background 'light up' when playlist is touched
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
