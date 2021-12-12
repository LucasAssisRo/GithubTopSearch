//
//  URLImageView.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import Alamofire
import UIKit

// MARK: - URLImageView

final class URLImageView: UIImageView {
    private var request: CancelOnDeninitRequest?

    func loadImage(fromStringURL url: String) {
        request = AF.request(url, method: .get)
            .response { [weak self] in self?.image = (try? $0.result.get()).flatMap(UIImage.init(data:)) }
            .cancelOnDeinit()
    }
}
