//
//  SpotifyPlaylistCollectionViewCell.swift
//  Playlister
//
//  Created by Martijn Bogaert on 13/08/2021.
//

import UIKit

class SpotifyPlaylistCollectionViewCell: PlaylistCollectionViewCell {
    @IBOutlet weak var separatorLineView: UIView!
    @IBOutlet weak var separatorLineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make playlist cover have rounded corners
        coverImageView.layer.cornerRadius = 5
        coverImageView.clipsToBounds = true
        
        // Set height of separator line to 1 pixel
        separatorLineHeightConstraint?.constant = 1 / UITraitCollection.current.displayScale
    }
}
