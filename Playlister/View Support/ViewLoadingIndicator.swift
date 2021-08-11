//
//  ViewLoadingIndicator.swift
//  Playlister
//
//  Created by Martijn Bogaert on 10/08/2021.
//

// SOURCE: https://gist.github.com/nguyentruongky/0e9a3ec53fe5e5fb5f9ba64328b2db79

import UIKit

extension UIView {
    static let loadingViewTag = 1938123987
    func showLoading(style: UIActivityIndicatorView.Style = .medium, color: UIColor? = nil, scale: CGFloat = 1) {
        var loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        if loading == nil {
            loading = UIActivityIndicatorView(style: style)
        }
        //loading?.scale(value: scale)
        if let color = color {
            loading?.color = color
        }
        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingViewTag
        addSubview(loading!)
        loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        loading?.removeFromSuperview()
    }
}
