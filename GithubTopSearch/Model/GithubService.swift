//
//  GithubService.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 09.12.21.
//

import Alamofire
import Foundation

// MARK: - GithubService

protocol GithubService {
    func getRepositories(
        in timePeriod: TimePeriod,
        with query: String?,
        _ completion: @escaping (Result<[Repository], Error>) -> Void
    )
        -> CancelOnDeninitRequest?
}

// MARK: - LiveGithubService

struct LiveGithubService: GithubService {
    func getRepositories(
        in timePeriod: TimePeriod,
        with query: String?,
        _ completion: @escaping (Result<[Repository], Error>) -> Void
    ) -> CancelOnDeninitRequest? {
        struct Response: Decodable { let items: [Repository] }
        struct Query: Encodable {
            let q: String
            let per_page = 20
            let sort = "stars"
        }
        
        return AF.request(
            "https://api.github.com/search/repositories",
            method: .get,
            parameters: Query(q: "created:>=\(timePeriod.query) \"\(query ?? "")\" in:name"),
            encoder: URLEncodedFormParameterEncoder(destination: .queryString)
        )
        .responseDecodable(of: Response.self) {
            completion($0.result.map(\.items).mapError { $0 as Error })
        }
        .cancelOnDeinit()
    }
}
