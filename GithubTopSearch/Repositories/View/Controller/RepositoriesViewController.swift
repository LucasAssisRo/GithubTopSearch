//
//  RepositoriesViewController.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 09.12.21.
//

import RxCocoa
import RxSwift
import UIKit

// MARK: - RepositoriesViewController

final class RepositoriesViewController: UIViewController {
    var selectedRepository: Repository?
    var viewModel: RepositoriesViewModel = LiveRepositoriesViewModel()
    private var disposeBag: DisposeBag?

    private var canRequest = true

    var dataSource: [RepositoryItem] = [] {
        didSet {
            setEmptyLabelVisibility()
            applySnapshot()
        }
    }

    var diffableDataSource: RepositoryDiffableDataSource!

    private var canFetchMoreFromScroll = true

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = makeCompositionalLayout(sizeClass: traitCollection.horizontalSizeClass)
        diffableDataSource = makeDiffableDatasource()
        diffableDataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "searchHeader",
                for: indexPath
            ) as! SearchCollectionReusableView

            header.didTypeSearch = { [weak self] in self?.viewModel.query = $0 }
            return header
        }

        disposeBag = .init(
            disposing: [
                viewModel.repositories.drive { [weak self] in
                    self?.dataSource = $0.map(RepositoryItem.item)
                },
                viewModel.requestAvailable.drive { [weak self] in self?.canRequest = $0 },
                viewModel.limitReached.emit(onNext: { [weak self] in self?.presentLimitReachedAlert() }),
            ]
        )
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

    @IBAction func selectedTimePeriod(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: viewModel.timePeriod = .day
        case 1: viewModel.timePeriod = .week
        case 2: viewModel.timePeriod = .month
        default: fatalError("Invalid index on segmented control, add more cases or remove number of segments")
        }
    }

    @IBAction func clearSearch(_ sender: UIBarButtonItem) {
        viewModel.query = nil
    }

    private func presentLimitReachedAlert() {
        let alert = UIAlertController(
            title: "alert.limit_reached.title".localized,
            message: "alert.limit_reached.message".localized,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "main.ok".localized, style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - RepositoriesViewController + UICollectionViewDelegate

extension RepositoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(at: indexPath, in: collectionView)
    }
}

// MARK: - RepositoriesViewController + RepositoryCollection

extension RepositoriesViewController: RepositoryCollection {
    var hasSectionHeader: Bool { true }
}

// MARK: - RepositoriesViewController + UIScrollViewDelegate

extension RepositoriesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canRequest, scrollView.contentSize.height - scrollView.contentOffset.y > 50
        else { return }
        viewModel.requestRepositories()
    }
}
