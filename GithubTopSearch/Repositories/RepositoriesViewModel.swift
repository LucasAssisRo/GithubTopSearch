//
//  RepositoriesViewModel.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import RxCocoa
import RxRelay

// MARK: - RepositoriesViewModel

protocol RepositoriesViewModel {
    var repositories: Driver<[Repository]> { get }
    var timePeriod: TimePeriod { get set }
    var query: String? { get set }

    func requestRepositories()
}

// MARK: - LiveRepositoriesViewModel

final class LiveRepositoriesViewModel: RepositoriesViewModel {
    private let githubRepositories = BehaviorRelay<[Repository]>(value: [])
    var repositories: Driver<[Repository]> { githubRepositories.asDriver() }

    private let githubService: GithubService
    private var getRepositoriesRequest: CancelOnDeninitRequest?

    var timePeriod: TimePeriod = .day {
        didSet { requestRepositories() }
    }

    var query: String? {
        didSet { requestRepositories() }
    }

    init(
        githubService: GithubService = LiveGithubService()
    ) {
        self.githubService = githubService
        requestRepositories()
    }

    func requestRepositories() {
        if query?.isEmpty == true {
            githubRepositories.accept([])
        } else {
            getRepositoriesRequest = LiveGithubService().getRepositories(in: timePeriod, with: query) { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case let .success(repositories): self.githubRepositories.accept(repositories)
                case .failure: return
                }
            }
        }
    }
}
