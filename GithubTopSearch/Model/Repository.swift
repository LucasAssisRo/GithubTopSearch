//
//  Repository.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Foundation

struct Repository: Codable, Hashable {
    struct Owner: Codable, Hashable {
        let login: String
        let avatar_url: String
    }

    let id: Int
    let name: String
    let owner: Owner
    let description: String?
    let stargazers_count: Int
    let language: String?
    let forks: Int
    let created_at: String
    let html_url: String
}
