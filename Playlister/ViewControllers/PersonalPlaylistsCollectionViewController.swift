//
//  PersonalPlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 02/08/2021.
//

import UIKit

class PersonalPlaylistsCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var dataSource: DataSourceType!
    var model = Model()
    
    enum ViewModel {
        enum Section: Hashable {
            case spotify
        }
        
        enum Item: Hashable {
            case spotifyPlaylist(_ playlist: SpotifyPlaylist)
        }
    }
    
    struct Model {
        var spotifyPlaylists = [SpotifyPlaylist]()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    func update() {
        print("update")
        if let token = Storage.shared.spotifyTokens?.accessToken {
            SpotifyPersonalPlaylistsRequest(accessToken: token).send { result in
                switch result {
                case .success(let spotifyPagingObject):
                    self.model.spotifyPlaylists = spotifyPagingObject.playlists
                case .failure:
                    self.model.spotifyPlaylists = []
                }
                
                DispatchQueue.main.async {
                    self.updateCollectionView()
                }
            }
        }
    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        sectionIDs.append(.spotify)
        itemsBySection[.spotify] = model.spotifyPlaylists.map({ .spotifyPlaylist($0) })
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyPlaylist", for: indexPath) as! PlaylistCollectionViewCell
            
            if case .spotifyPlaylist(let playlist) = item {
                cell.titleLabel.text = playlist.name
            }
            
            return cell
        }
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .spotify:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(230))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = .fixed(10)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                section.interGroupSpacing = 10
                
                return section
            }
        }
    }

    @IBAction func unwindFromUserDetailsViewController(unwindSegue: UIStoryboardSegue) { }
    
}
