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
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        coverImageView.layer.cornerRadius = 5
        coverImageView.clipsToBounds = true
        
        separatorLineHeightConstraint.constant = 1 / UITraitCollection.current.displayScale
    }
}
