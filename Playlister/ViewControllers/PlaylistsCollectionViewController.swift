//
//  PlaylistsCollectionViewController.swift
//  Playlister
//
//  Created by Martijn Bogaert on 13/08/2021.
//

import UIKit
import SafariServices
import MediaPlayer

class PlaylistsCollectionViewController: UICollectionViewController, SFSafariViewControllerDelegate {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var dataSource: DataSourceType!
    var model = Model()
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case saved
            case spotify
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.saved, _):
                    return true
                default:
                    return false
                }
            }
        }
        
        enum Item: Hashable, Comparable {
            case savedPlaylist(_ playlist: Playlist)
            case spotifyPlaylist(_ playlist: SpotifyPlaylist)
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.savedPlaylist(let lPlaylist), .savedPlaylist(let rPlaylist)):
                    return lPlaylist < rPlaylist
                default:
                    return true
                }
            }
        }
    }
    
    struct Model {
        var savedPlaylists = [Playlist]()
        var spotifyPlaylists = [SpotifyPlaylist]()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
    }
    
    func update() {
        updateCollectionView()
    }
    
    func updateCollectionView() {
        var itemsBySection = [ViewModel.Section: [ViewModel.Item]]()
        
        if !model.savedPlaylists.isEmpty {
            itemsBySection[.saved] = model.savedPlaylists.map { .savedPlaylist($0) }.sorted(by: >)
        }
        
        let spotifyPlaylists = model.spotifyPlaylists.reduce(into: [ViewModel.Item]()) { partial, spotifyPlaylist in
            if !model.savedPlaylists.contains(where: { $0.spotifyId == spotifyPlaylist.id }) {
                partial.append(.spotifyPlaylist(spotifyPlaylist))
            }
        }
        
        if !spotifyPlaylists.isEmpty {
            itemsBySection[.spotify] = spotifyPlaylists
        }
        
        dataSource.applySnapshotUsing(sectionIDs: itemsBySection.keys.sorted(), itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .savedPlaylist(let playlist):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedPlaylist", for: indexPath) as! SavedPlaylistCollectionViewCell
                
                cell.titleLabel.text = playlist.name
                cell.coverImageView.image = UIImage(systemName: "music.note.list")
                
                if let data = playlist.coverImageData {
                    cell.coverImageView.image = UIImage(data: data)
                }
                
                return cell
            case .spotifyPlaylist(let playlist):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotifyPlaylist", for: indexPath) as! SpotifyPlaylistCollectionViewCell
                
                cell.titleLabel.text = playlist.name
                cell.coverImageView.image = UIImage(systemName: "music.note.list")
                
                if indexPath.row + 1 == collectionView.numberOfItems(inSection: indexPath.section) {
                    cell.separatorLineView.isHidden = true
                } else {
                    cell.separatorLineView.isHidden = false
                }
                
                if let spotifyImage = playlist.images.first {
                    SpotifyImageRequest(fromURL: spotifyImage.url)?.send { result in
                        if case .success(let image) = result {
                            DispatchQueue.main.async {
                                cell.coverImageView.image = image
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.coverImageView.image = UIImage(systemName: "music.note.list")
                            }
                        }
                    }
                }
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            let snapshot = dataSource.snapshot()
            
            if case SupplementaryViewKind.header = kind, case .spotify = snapshot.sectionIdentifiers[indexPath.section], let _ = snapshot.indexOfSection(.saved) {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
                headerView.titleLable.text = "Spotify"
                return headerView
            }
            
            return nil
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .saved:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                section.interGroupSpacing = 10
                
                return section
            case .spotify:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                section.interGroupSpacing = 0
                
                if let _ = self.dataSource.snapshot().indexOfSection(.saved) {
                    let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(29))
                    let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .top)
                    headerItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                    section.boundarySupplementaryItems = [headerItem]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                }
                
                return section
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            
            func createPlaylistActionFromId(_ playlistId: String) -> UIMenuElement {
                return UIAction(title: "Open in Spotify", image: UIImage(systemName: "arrow.up.forward.app")) { _ in
                    var urlComponents = URLComponents()
                    urlComponents.scheme = "https"
                    urlComponents.host = "open.spotify.com"
                    urlComponents.path = "/playlist/\(playlistId)"
                    
                    if let url = urlComponents.url {
                        let safariViewController = SFSafariViewController(url: url)
                        safariViewController.delegate = self
                        self.present(safariViewController, animated: true)
                    }
                }
            }
            
            var menuElements = [UIMenuElement]()
            
            switch item {
            case .savedPlaylist(let savedPlaylist):
                let removeAction = UIAction(title: "Remove Playlist", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    self.removeSavedPlaylist(savedPlaylist)
                    self.update()
                }
                
                menuElements.append(createPlaylistActionFromId(savedPlaylist.spotifyId))
                menuElements.append(removeAction)
            case .spotifyPlaylist(let spotifyPlaylist):
                menuElements.append(createPlaylistActionFromId(spotifyPlaylist.id))
            }
            
            return UIMenu(children: menuElements)
        }
    }
    
    func removeSavedPlaylist(_ playlist: Playlist) { }

    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {
        update()
    }
    
    enum SupplementaryViewKind {
        static let header = "header"
    }
    
}
