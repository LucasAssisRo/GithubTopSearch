//
//  FavoritesViewModel.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

// MARK: - FavoritesViewModel

protocol FavoritesViewModel {
    var favorites: Driver<[Repository]> { get }
}

// MARK: - LiveFavoritesViewModel

final class LiveFavoritesViewModel: FavoritesViewModel {
    private let favoritesRelay = BehaviorRelay<[Repository]>(
        value: LiveFavoritesViewModel.sortedFavorites(from: UserDefaults.favoriteRepositories)
    )

    var favorites: Driver<[Repository]> { favoritesRelay.asDriver() }

    private var disposeBag = DisposeBag()

    init() {
        disposeBag.insert(
            UserDefaults
                .standard
                .rx
                .observe(Data.self, UserDefaults.favoriteRepositoriesKey)
                .compactMap { try $0.map { try JSONDecoder().decode(Set<Repository>.self, from: $0) } }
                .subscribe(onNext: { [weak self] in
                    self?.favoritesRelay.accept(Self.sortedFavorites(from: $0))
                })
        )
    }

    private static func sortedFavorites(from set: Set<Repository>) -> [Repository] {
        .init(set).sorted { $0.stargazers_count > $1.stargazers_count }
    }
}
