//
//  FavoritesViewController.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import RxSwift
import UIKit

// MARK: - FavoritesViewController

final class FavoritesViewController: UIViewController {
    var dataSource: [RepositoryItem] = [] {
        didSet {
            setEmptyLabelVisibility()
            applySnapshot()
        }
    }

    var viewModel: FavoritesViewModel = LiveFavoritesViewModel()
    private var disposeBag: DisposeBag?

    var diffableDataSource: RepositoryDiffableDataSource!

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = makeCompositionalLayout(sizeClass: traitCollection.horizontalSizeClass)
        diffableDataSource = makeDiffableDatasource()
        disposeBag = .init {
            viewModel.favorites.drive { [weak self] in
                self?.dataSource = $0.map(RepositoryItem.item)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setEmptyLabelVisibility()
    }

    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        transition(to: newCollection, with: coordinator)
    }
}

// MARK: - FavoritesViewController + UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(at: indexPath, in: collectionView)
    }
}

// MARK: - FavoritesViewController + RepositoryCollection

extension FavoritesViewController: RepositoryCollection {
    var hasSectionHeader: Bool { false }
}
