//
//  TripViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//


import UIKit
import CoreData
import GooglePlaces
import GoogleMaps

class TripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var places : [Place] = []
  var placeViewController: PlaceDetailsViewController? = nil
  
  @IBOutlet weak var tableView: UITableView!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navbarSetup()
    tableGestureSetup()
    
    tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func navbarSetup() {
    navigationItem.leftBarButtonItem = editButtonItem
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
  }
  
  func tableGestureSetup() {
    tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    
    let longpress = UILongPressGestureRecognizer(target: self, action: #selector(TripViewController.longPressGestureRecognized(_:)))
    
    tableView.addGestureRecognizer(longpress)
  }
  
  func insertNewObject(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
  }
  
  func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
    let longPress = gestureRecognizer as! UILongPressGestureRecognizer
    let state = longPress.state
    let locationInView = longPress.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: locationInView)
    
    struct My {
      static var cellSnapshot : UIView? = nil
      static var cellIsAnimating : Bool = false
      static var cellNeedToShow : Bool = false
    }
    struct Path {
      static var initialIndexPath : IndexPath? = nil
    }
    
    switch state {
    case UIGestureRecognizerState.began:
      if indexPath != nil {
        Path.initialIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
        My.cellSnapshot  = snapshotOfCell(cell!)
        
        var center = cell?.center
        My.cellSnapshot!.center = center!
        My.cellSnapshot!.alpha = 0.0
        tableView.addSubview(My.cellSnapshot!)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
          center?.y = locationInView.y
          My.cellIsAnimating = true
          My.cellSnapshot!.center = center!
          My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
          My.cellSnapshot!.alpha = 0.98
          cell?.alpha = 0.0
        }, completion: { (finished) -> Void in
          if finished {
            My.cellIsAnimating = false
            if My.cellNeedToShow {
              My.cellNeedToShow = false
              UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cell?.alpha = 1
              })
            } else {
              cell?.isHidden = true
            }
          }
        })
      }
      
    case UIGestureRecognizerState.changed:
      if My.cellSnapshot != nil {
        var center = My.cellSnapshot!.center
        center.y = locationInView.y
        My.cellSnapshot!.center = center
        
        if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
          places.insert(places.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
          tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
          Path.initialIndexPath = indexPath
          tableView.reloadData()
        }
      }
    default:
      if Path.initialIndexPath != nil {
        let cell = tableView.cellForRow(at: Path.initialIndexPath!) as UITableViewCell!
        if My.cellIsAnimating {
          My.cellNeedToShow = true
        } else {
          cell?.isHidden = false
          cell?.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
          My.cellSnapshot!.center = (cell?.center)!
          My.cellSnapshot!.transform = CGAffineTransform.identity
          My.cellSnapshot!.alpha = 0.0
          cell?.alpha = 1.0
          
        }, completion: { (finished) -> Void in
          if finished {
            Path.initialIndexPath = nil
            My.cellSnapshot!.removeFromSuperview()
            My.cellSnapshot = nil
          }
        })
      }
    }
  }
  
  func snapshotOfCell(_ inputView: UIView) -> UIView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
    inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let cellSnapshot : UIView = UIImageView(image: image)
    cellSnapshot.layer.masksToBounds = false
    cellSnapshot.layer.cornerRadius = 0.0
    cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
    cellSnapshot.layer.shadowRadius = 5.0
    cellSnapshot.layer.shadowOpacity = 0.4
    return cellSnapshot
  }
  
  // MARK: - Table view data source
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
    
    cell.setup(place: places[indexPath.row])
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //    tableView.deselectRow(at: indexPath, animated: false)
    
    performSegue(withIdentifier: "goToPlaceDetailsSegue", sender: self)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120.0
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      self.places.remove(at: indexPath.row)
      self.tableView.deleteRows(at: [indexPath], with: .automatic)
      self.tableView.reloadData()
    }
  }
  
  // MARK: - Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToPlaceDetailsSegue" {
      if let indexPath = tableView.indexPathForSelectedRow {
        
        let placeVC = segue.destination as! PlaceDetailsViewController
        
        placeVC.place = places[indexPath.row]
      }
    }
  }
}

extension TripViewController: GMSAutocompleteViewControllerDelegate {
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    dismiss(animated: true, completion: {
      
      let place = Place(place: place)
      self.places.append(place)
      self.tableView.reloadData()
      
    })
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }
  
  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
}


