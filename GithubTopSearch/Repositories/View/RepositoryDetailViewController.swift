//
//  RepositoryDetailViewController.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 11.12.21.
//

import UIKit

final class RepositoryDetailViewController: UIViewController {
    var repository: Repository!

    @IBOutlet private var info: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var language: UILabel!
    @IBOutlet private var forks: UILabel!
    @IBOutlet private var stars: UILabel!
    @IBOutlet private var clock: UILabel!
    @IBOutlet private var goToGithub: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = info
        tableView.tableFooterView = goToGithub
    }
}
