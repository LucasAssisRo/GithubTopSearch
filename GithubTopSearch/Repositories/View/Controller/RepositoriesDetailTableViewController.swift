//
//  RepositoriesDetailTableViewController.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 11.12.21.
//

import SafariServices
import UIKit

final class RepositoriesDetailTableViewController: UITableViewController {
    struct RepositoryDetail {
        let name: String
        let info: String
        let language: String
        let forks: Int
        let stars: Int
        let createDate: String
        let link: URL
    }

    var repository: RepositoryDetail!

    @IBOutlet private var language: UILabel!
    @IBOutlet private var forks: UILabel!
    @IBOutlet private var stars: UILabel!
    @IBOutlet private var createDate: UILabel!

    @IBOutlet private var openInGithub: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        openInGithub.layer.cornerRadius = 16
        openInGithub.clipsToBounds = true

        title = repository.name
        language.text = repository.language
        forks.text = String.countSensitiveLocalized(
            singularString: "main.forks.singular",
            pluralString: "main.forks.plural",
            count: repository.forks
        )
        stars.text = String.countSensitiveLocalized(
            singularString: "main.stars.singular",
            pluralString: "main.stars.plural",
            count: repository.stars
        )

        createDate.text = createDateText
    }

    private var createDateText: String {
        let githubDateFormatter = ISO8601DateFormatter()
        let date = githubDateFormatter.date(from: repository.createDate)!
        let relativeTimeFormatter = RelativeDateTimeFormatter()
        let relativeDate = relativeTimeFormatter.localizedString(for: date, relativeTo: .init())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let prettyDate = dateFormatter.string(from: date)
        return "repository.detail.created_at".localized(
            arg1: relativeDate,
            arg2: prettyDate
        )
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        repository.info
    }

    @IBAction func onGoToGithub(_ sender: UIButton) {
        present(SFSafariViewController(url: repository.link), animated: true)
    }
}
