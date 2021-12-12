//
//  Icon.swift
//  GithubTopSearch
//
//  Created by Lucas Assis Rodrigues on 10.12.21.
//

import UIKit

enum Icon {
    case heartOutline
    case heart

    var image: UIImage {
        switch self {
        case .heart: return UIImage(named: "heart-filled")!
        case .heartOutline: return UIImage(named: "heart-empty")!
        }
    }
}


extension UIButton {
    func set(icon: Icon, for state: UIButton.State) {
        setImage(icon.image, for: state)
    }
}
