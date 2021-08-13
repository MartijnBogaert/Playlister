//
//  SectionHeaderView.swift
//  Playlister
//
//  Created by Martijn Bogaert on 13/08/2021.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "SectionHeaderView"
    
    let titleLable: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLable)
        
        NSLayoutConstraint.activate(
            [titleLable.leadingAnchor.constraint(equalTo: leadingAnchor),
             titleLable.trailingAnchor.constraint(equalTo: trailingAnchor),
             titleLable.centerYAnchor.constraint(equalTo: centerYAnchor)]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
