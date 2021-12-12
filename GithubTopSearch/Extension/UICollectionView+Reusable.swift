//
//  UICollectionView+Reusable.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import UIKit

// MARK: - CollectionReusable

protocol CollectionReusable: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension UICollectionView {
    func registerCell<Cell: CollectionReusable>(ofClass cell: Cell.Type) {
        register(cell.self, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

    func dequeueReusableCell<Cell: CollectionReusable>(ofType type: Cell.Type, for indexPath: IndexPath) -> Cell {
        dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
}
