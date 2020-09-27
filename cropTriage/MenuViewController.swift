//
//  MenuViewController.swift
//  cropTriage
//
//  Created by Blake Carr on 9/26/20.
//

import UIKit

// all menus
enum MenuType: Int{
    case Home
    case Drone
    case Crop
    case Settings
}

class MenuViewController: UITableViewController {
    
    var tappedMenu: ((MenuType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) {
            print("Changing to menu: \(menuType)")
            self.tappedMenu?(menuType)
        }
    }

}
