//
//  UIStoryboard+.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 11.12.21.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard { UIStoryboard(name: "Main", bundle: nil) }
    
    func makeRepositoryDetailTableViewController() -> RepositoriesDetailTableViewController {
        instantiateViewController(withIdentifier: "RepositoryDetail") as! RepositoriesDetailTableViewController
    }
}
