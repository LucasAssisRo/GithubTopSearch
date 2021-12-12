//
//  GithubService.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 09.12.21.
//

import Alamofire
import Foundation

// MARK: - GithubService

typealias GithubServiceResponse = (
    repositories: [Repository],
    hasNextPage: Bool,
    requestsRemaining: Int,
    rateLimitReset: TimeInterval
)

// MARK: - GithubService

protocol GithubService {
    func getRepositories(
        in timePeriod: TimePeriod,
        with query: String?,
        page: Int,
        _ completion: @escaping (Result<GithubServiceResponse, Error>) -> Void
    )
        -> CancelOnDeninitRequest?
}

// MARK: - LiveGithubService

struct LiveGithubService: GithubService {
    func getRepositories(
        in timePeriod: TimePeriod,
        with query: String?,
        page: Int,
        _ completion: @escaping (Result<GithubServiceResponse, Error>) -> Void
    ) -> CancelOnDeninitRequest? {
        struct Response: Decodable {
            let items: [Repository]
        }
        struct Query: Encodable {
            let q: String
            let per_page = 20
            let sort = "stars"
            let page: Int
        }

        return AF.request(
            "https://api.github.com/search/repositories",
            method: .get,
            parameters: Query(q: "created:>=\(timePeriod.query) \"\(query ?? "")\" in:name", page: page),
            encoder: URLEncodedFormParameterEncoder(destination: .queryString)
        )
        .responseDecodable(of: Response.self) { value in
            completion(
                value.result
                    .map(\.items)
                    .map {
                        (
                            repositories: $0,
                            hasNextPage: value.response?.headers["Link"]?.contains("next") == true,
                            requestsRemaining: value.response?.headers["x-ratelimit-remaining"].flatMap(Int.init) ?? 0,
                            rateLimitReset: value.response?.headers["x-ratelimit-reset"].flatMap(TimeInterval.init) ?? 0
                        )
                    }
                    .mapError { $0 as Error }
            )
        }
        .cancelOnDeinit()
    }
}
