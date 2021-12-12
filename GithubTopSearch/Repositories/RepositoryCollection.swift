//
//  RepositoryCollection.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 11.12.21.
//

import UIKit

typealias RepositoryDiffableDataSource = UICollectionViewDiffableDataSource<RepositorySection, RepositoryItem>
typealias RepositorySnapshot = NSDiffableDataSourceSnapshot<RepositorySection, RepositoryItem>

// MARK: - RepositorySection

enum RepositorySection { case single }

// MARK: - RepositoryItem

enum RepositoryItem: Hashable { case item(repository: Repository) }

// MARK: - RepositoryCollection

protocol RepositoryCollection: UIViewController {
    var hasSectionHeader: Bool { get }
    var collectionView: UICollectionView! { get set }
    var emptyLabel: UILabel! { get set }
    var diffableDataSource: RepositoryDiffableDataSource! { get set }
    var dataSource: [RepositoryItem] { get set }
}

extension RepositoryCollection {
    func setEmptyLabelVisibility() {
        UIView.animate(withDuration: 0.2) { [self] in
            self.emptyLabel.alpha = self.dataSource.isEmpty ? 1 : 0
        }
    }

    func applySnapshot() {
        var snapshot = RepositorySnapshot()
        snapshot.appendSections([.single])
        snapshot.appendItems(dataSource, toSection: .single)
        diffableDataSource.apply(snapshot)
    }

    func makeCompositionalLayout(sizeClass: UIUserInterfaceSizeClass) -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitem: .init(layoutSize: size),
            count: sizeClass == .regular ? 2 : 1
        )
        let section = NSCollectionLayoutSection(
            group: group
        )

        section.interGroupSpacing = 24
        section.supplementariesFollowContentInsets = true

        if hasSectionHeader {
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(56)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            section.boundarySupplementaryItems = [header]
        }

        return UICollectionViewCompositionalLayout(section: section)
    }

    func makeDiffableDatasource() -> RepositoryDiffableDataSource {
        .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .item(repository: repository):
                return collectionView.dequeueReusableCell(
                    ofType: RepositoryCollectionViewCell.self,
                    for: indexPath
                )
                .binding(
                    bindings: .init(
                        repoName: repository.name,
                        owner: repository.owner.login,
                        avatar: repository.owner.avatar_url,
                        info: repository.description,
                        stars: repository.stargazers_count,
                        id: repository.id
                    )
                ) {
                    if !$0 { UserDefaults.favoriteRepositories.remove(repository) }
                    else { UserDefaults.favoriteRepositories.insert(repository) }
                }
            }
        }
    }

    func transition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        guard newCollection.horizontalSizeClass != traitCollection.horizontalSizeClass else { return }
        collectionView.collectionViewLayout = makeCompositionalLayout(sizeClass: newCollection.horizontalSizeClass)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func didSelectItem(at indexPath: IndexPath, in collectionView: UICollectionView) {
        switch dataSource[indexPath.item] {
        case let .item(repository: repository):
            pushRepositoryDetailViewController(with: repository)
            if !UserDefaults.visitedRepositories.contains(repository.id) {
                UserDefaults.visitedRepositories.append(repository.id)
                reloadCell(for: repository)
            }
        }
    }

    private func pushRepositoryDetailViewController(with repository: Repository) {
        let detail = UIStoryboard.main.makeRepositoryDetailTableViewController()
        detail.repository = .init(
            name: repository.name,
            info: repository.description ?? "main.no_description".localized,
            language: repository.language ?? "main.not_specified".localized,
            forks: repository.forks,
            stars: repository.stargazers_count,
            createDate: repository.created_at,
            link: URL(string: repository.html_url)!
        )
        navigationController!.pushViewController(detail, animated: true)
    }

    private func reloadCell(for repository: Repository) {
        var snapshot = diffableDataSource.snapshot()
        snapshot.reloadItems([.item(repository: repository)])
        diffableDataSource.apply(snapshot)
    }
}
