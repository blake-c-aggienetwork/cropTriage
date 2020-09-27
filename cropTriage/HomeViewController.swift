//
//  ViewController.swift
//  cropTriage
//
//  Created by Blake Carr on 9/25/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Change font of title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
         NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 21)!]
        
    }

    
    @IBAction func tappedMenu(_ sender: Any) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.tappedMenu = { MenuType in self.transitionToNew(MenuType) }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
    
    func transitionToNew(_ menuType: MenuType){
        title = ""
        
        // remove previous menu
        topView?.removeFromSuperview()
        
        // switch to desired menu
        switch menuType {
        case .Home:
            title = "Home"
        case .Drone:
            title = "Drone Config"
            let view = UIView()
            view.backgroundColor = .yellow
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .Crop:
            title = "Crop Data"
            let view = UIView()
            view.backgroundColor = .blue
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        case .Settings:
            title = "Settings"
            let view = UIView()
            view.backgroundColor = .green
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
        }
        self.title = title
        
    }
    
    

}

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
