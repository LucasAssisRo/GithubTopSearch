//
//  RepositoriesViewModel.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Foundation
import RxCocoa
import RxRelay

// MARK: - RepositoriesViewModel

protocol RepositoriesViewModel {
    var repositories: Driver<[Repository]> { get }
    var requestAvailable: Driver<Bool> { get }
    var limitReached: Signal<Void> { get }

    var timePeriod: TimePeriod { get set }
    var query: String? { get set }

    func requestRepositories()
}

// MARK: - LiveRepositoriesViewModel

final class LiveRepositoriesViewModel: RepositoriesViewModel {
    private struct PageInfo {
        var index: Int
        var hasNext: Bool

        static var initial: Self { .init(index: 1, hasNext: true) }
    }

    private let requestAvailableRelay = BehaviorRelay(value: true)
    var requestAvailable: Driver<Bool> { requestAvailableRelay.asDriver() }

    private let githubRepositories = BehaviorRelay<[Repository]>(value: [])
    var repositories: Driver<[Repository]> { githubRepositories.asDriver() }

    private let limitReachedRelay = PublishRelay<Void>()
    var limitReached: Signal<Void> { limitReachedRelay.asSignal() }

    private let githubService: GithubService
    private var getRepositoriesRequest: CancelOnDeninitRequest?

    var timePeriod: TimePeriod = .day {
        didSet {
            pageInfo = .initial
            requestRepositories()
        }
    }

    var query: String? {
        didSet {
            pageInfo = .initial
            requestRepositories()
        }
    }

    private var remainingRequests = Int.max {
        didSet {
            requestAvailableRelay.accept(remainingRequests > 0)
        }
    }

    private var requestResetTimer: Timer? {
        willSet { requestResetTimer?.invalidate() }
    }

    private var pageInfo = PageInfo.initial

    init(
        githubService: GithubService = LiveGithubService()
    ) {
        self.githubService = githubService
        requestRepositories()
    }

    deinit { requestResetTimer?.invalidate() }

    func requestRepositories() {
        if query?.isEmpty == true {
            githubRepositories.accept([])
        } else if pageInfo.hasNext {
            let pageIndex = pageInfo.index
            pageInfo.index += 1
            requestAvailableRelay.accept(pageIndex == 1 && remainingRequests > 0)
            getRepositoriesRequest = LiveGithubService().getRepositories(
                in: timePeriod,
                with: query,
                page: pageIndex
            ) { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case let .success(response):
                    self.requestResetTimer = .scheduledTimer(
                        withTimeInterval: response.rateLimitReset,
                        repeats: false
                    ) { [weak self] _ in
                        guard let self = self else { return }
                        self.remainingRequests = .max
                    }

                    var updatedRepositories = self.pageInfo.index > 1 ? self.githubRepositories.value : []
                    updatedRepositories.append(contentsOf: response.repositories)

                    self.remainingRequests = response.requestsRemaining

                    self.pageInfo.hasNext = response.hasNextPage

                    self.githubRepositories.accept(updatedRepositories)

                case .failure:
                    self.pageInfo.index -= 1
                }

                if self.remainingRequests == 0 { self.limitReachedRelay.accept(()) }
            }
        }
    }
}
