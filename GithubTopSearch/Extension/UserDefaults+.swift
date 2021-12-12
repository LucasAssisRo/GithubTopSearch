//
//  UserDefaults+.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Foundation

extension UserDefaults {
    // TODO: Not ideal solution, move to sql database
    static var favoriteRepositoriesKey: String { "favoriteRepositories" }
    static var favoriteRepositories: Set<Repository> {
        get {
            standard.data(forKey: favoriteRepositoriesKey)
                .map { try! JSONDecoder().decode(Set<Repository>.self, from: $0) } ?? []
        }

        set {
            standard.set(try! JSONEncoder().encode(newValue), forKey: favoriteRepositoriesKey)
        }
    }

    static var favoritesKey: String { "favorites" }
    static var favorites: [Int] {
        get { standard.value(forKey: favoritesKey) as? [Int] ?? [] }
        set { standard.set(newValue, forKey: favoritesKey) }
    }

    static var visitedRepositoriesKey: String { "visited" }
    static var visitedRepositories: [Int] {
        get { standard.value(forKey: visitedRepositoriesKey) as? [Int] ?? [] }
        set { standard.set(newValue, forKey: visitedRepositoriesKey) }
    }
}
