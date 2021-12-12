//
//  Request+.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Alamofire

// MARK: - CancelOnDeninitRequest

/// Request wrapper that cancels when deinitialized.
///
/// Useful for avoiding race conditions.
final class CancelOnDeninitRequest {
    private let request: Request
    init(request: Request) { self.request = request }
    deinit { request.cancel() }
}

extension Request {
    func cancelOnDeinit() -> CancelOnDeninitRequest { .init(request: self) }
}
