//
//  LandingViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
  
  //MARK: Properties
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    get {
      return UIInterfaceOrientationMask.portrait
    }
  }
  
  //MARK: Push to relevant ViewController
  func pushTo(viewController: ViewControllerType)  {
    switch viewController {
    case .places:
      let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavigationViewController
      self.present(vc, animated: false, completion: nil)
    case .welcome:
      let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
      self.present(vc, animated: false, completion: nil)
    }
  }
  
  //MARK: Check if user is signed in or not
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
      let email = userInformation["email"] as! String
      let password = userInformation["password"] as! String
      User.loginUser(withEmail: email, password: password, completion: { [weak weakSelf = self] (status) in
        DispatchQueue.main.async {
          if status == true {
            weakSelf?.pushTo(viewController: .places)
          } else {
            weakSelf?.pushTo(viewController: .welcome)
          }
          weakSelf = nil
        }
      })
    } else {
      self.pushTo(viewController: .welcome)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
}
