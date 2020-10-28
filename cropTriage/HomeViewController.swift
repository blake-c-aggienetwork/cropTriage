//
//  ViewController.swift
//  cropTriage
//
//  Created by Blake Carr on 9/25/20.
//

import UIKit

// MARK: homeview controller
class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    let defaults = UserDefaults()
    var topView: UIView?
    var menuRef: MenuViewController?
    
    var isMenuOut: Bool?
    var menuIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Change font of title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
         NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 21)!]
        
        // Load last loaded menu
        menuIndex = defaults.integer(forKey: "menuIndex")
        
        self.transitionToNew(MenuType(rawValue: menuIndex) ?? .Home)
        
        
        
    }
    
    // function to open menu, is called through various taps and gestures
    func openMenu(){
        isMenuOut = true
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }
        menuRef = menuViewController
        
        menuViewController.tappedMenu = { MenuType in self.transitionToNew(MenuType) }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
    
    // This function effectively closes the menu and transitions to a new view
    // it is called in menuViewController
    func transitionToNew(_ menuType: MenuType){
        title = ""
        
        // remove previous menu
        topView?.removeFromSuperview()
        
        // switch to desired menu
        switch menuType {
        case .Home:
            title = "Home"
            self.title = title
        case .Drone:
            title = "Drone Config"
            self.title = title
            let view = droneView()
//            view.backgroundColor = .yellow
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .Crop:
            title = "Crop Data"
            self.title = title
            let view = UIView()
            view.backgroundColor = .blue
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .Settings:
            title = "Settings"
            self.title = title
            let view = UIView()
            view.backgroundColor = .green
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        }
        isMenuOut = false
        defaults.setValue(menuType.rawValue, forKey: "menuIndex")
//        self.title = title
        
    }
    
    
    // MARK: IBACTIONS
    // If user swipes right on main view then open side menu
    @IBAction func swipeAction(_ sender: Any) { openMenu() }
    
    // If user taps on menu button, then open menu
    @IBAction func tappedMenu(_ sender: Any) { openMenu() }
    

}


// MARK: menuViewController Extension
// Extension to conform to menuViewController
extension HomeViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
    
}
