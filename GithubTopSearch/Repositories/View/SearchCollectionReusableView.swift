//
//  SearchCollectionReusableView.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import UIKit

// MARK: - SearchCollectionReusableView

final class SearchCollectionReusableView: UICollectionReusableView {
    @IBOutlet var searchBar: UISearchBar!

    var didTypeSearch: ((_ search: String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                searchBar.topAnchor.constraint(equalTo: topAnchor),
                searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
                searchBar.leftAnchor.constraint(equalTo: leftAnchor),
                searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
}

// MARK: - SearchCollectionReusableView + UISearchBarDelegate

extension SearchCollectionReusableView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard searchBar.text?.isEmpty != false else { return }
        didTypeSearch?(searchBar.text)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        didTypeSearch?(searchText)
    }
}
