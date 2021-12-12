//
//  RepositoryCollectionViewCell.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 09.12.21.
//

import RxCocoa
import RxSwift
import UIKit

// MARK: - RepositoryCollectionViewCell

final class RepositoryCollectionViewCell: UICollectionViewCell {
    struct Bindings: Hashable {
        let repoName: String
        let owner: String
        let avatar: String
        let info: String?
        let stars: Int
        let id: Int
    }

    @IBOutlet private var avatar: URLImageView!

    @IBOutlet private var repoName: UILabel!
    @IBOutlet private var owner: UILabel!
    @IBOutlet private var info: UILabel!

    @IBOutlet private var stars: UILabel!
    @IBOutlet private var heart: UIButton!

    private var id: Int?
    private var onToggleFavorite: ((_ isFavorite: Bool) -> Void)?
    private var isFavorite: Bool { id.map(UserDefaults.favorites.contains) ?? false }

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 30
        UserDefaults
            .standard
            .rx
            .observe([Int].self, UserDefaults.favoritesKey)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] _ in self?.setHeartIcon() })
            .disposed(by: disposeBag)
    }

    func binding(bindings: Bindings, onToggleFavorite: @escaping (_ isFavorite: Bool) -> Void) -> Self {
        repoName.text = bindings.repoName
        owner.text = bindings.owner
        info.text = bindings.info ?? "main.no_description".localized
        stars.text = "\(bindings.stars)"
        avatar.loadImage(fromStringURL: bindings.avatar)
        id = bindings.id

        setHeartIcon()
        backgroundColor = UserDefaults.visitedRepositories.contains(bindings.id)
            ? .secondarySystemBackground
            : .systemBackground

        self.onToggleFavorite = onToggleFavorite
        return self
    }

    private func setHeartIcon() {
        heart.set(icon: isFavorite ? .heart : .heartOutline, for: .normal)
    }

    @IBAction private func toggledFavorite(_ sender: UIButton) {
        if let id = id {
            isFavorite
                ? UserDefaults.favorites.removeAll { $0 == id }
                : UserDefaults.favorites.append(id)
        }

        onToggleFavorite?(isFavorite)
        UIView.transition(
            with: heart,
            duration: 0.2,
            options: [.transitionCrossDissolve],
            animations: { self.heart.set(icon: self.isFavorite ? .heart : .heartOutline, for: .normal) },
            completion: nil
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
    }
}

// MARK: - RepositoryCollectionViewCell + CollectionReusable

extension RepositoryCollectionViewCell: CollectionReusable {
    static var reuseIdentifier: String { "repoCell" }
}
