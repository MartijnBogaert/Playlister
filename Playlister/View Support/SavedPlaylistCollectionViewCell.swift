//
//  SavedPlaylistCollectionViewCell.swift
//  Playlister
//
//  Created by Martijn Bogaert on 13/08/2021.
//

import UIKit

class SavedPlaylistCollectionViewCell: PlaylistCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make playlist contentView have rounded corners
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
}
