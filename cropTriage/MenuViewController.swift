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
    
    @IBOutlet weak var homeIcon: UIImageView!
    @IBOutlet weak var droneConfigIcon: UIImageView!
    @IBOutlet weak var cropDataIcon: UIImageView!
    @IBOutlet weak var settingsIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iconSize = CGSize(width: 30, height: 30)
        
        homeIcon.image = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: .black, size: iconSize)
        droneConfigIcon.image = UIImage.fontAwesomeIcon(name: .cogs, style: .solid, textColor: .black, size: iconSize)
        cropDataIcon.image = UIImage.fontAwesomeIcon(name: .tractor, style: .solid, textColor: .black, size: iconSize)
        settingsIcon.image = UIImage.fontAwesomeIcon(name: .slidersH, style: .solid, textColor: .black, size: iconSize)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        self.dismiss(animated: true) {
            print("Changing to menu: \(menuType)")
            self.tappedMenu?(menuType)
        }
    }

    
    
}
