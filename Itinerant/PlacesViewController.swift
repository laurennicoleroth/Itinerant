//
//  PlacesViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit

import UIKit
import RxSwift
import GoogleMaps
import RxGoogleMaps
import GooglePlaces
import CoreLocation
import CoreData

class PlacesViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var buildTripButton: UIButton!
  @IBOutlet var getStartedView: UIView!
  
  let disposeBag = DisposeBag()
  let locationManager = CLLocationManager()
  
  var placeObjects : [NSManagedObject] = [] {
    didSet {
      centerOnLastAdded()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
  
    addReactiveMapHandlers()
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    
    if placeObjects.count > 0 {
      getStartedView.isHidden = true
      centerOnLastAdded()
      addMarkersToMap(places: placeObjects)
    } else {
       locationManager.requestLocation()
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    placeObjects = fetchPlaces()
    addMarkersToMap(places: placeObjects)
    
    if placeObjects.count > 0 {
      getStartedView.isHidden = true
    }
  }
  
  func centerOnLastAdded() {
    if let last = placeObjects.last {
      let latitude = last.value(forKey: "latitude") as! Double
      let longitude = last.value(forKey: "longitude") as! Double
      
      centerTheMap(lat: latitude, lon: longitude)
    }

  }
  
  func addReactiveMapHandlers() {
    mapView.settings.myLocationButton = true
    
    let startLocationManager = mapView.rx.didTapMyLocationButton.take(1).publish()
    _ = startLocationManager.subscribe(onNext: { [weak self] in self?.locationManager.requestWhenInUseAuthorization() })
    _ = startLocationManager.map { true }.bind(to: mapView.rx.myLocationEnabled)
    startLocationManager.connect().addDisposableTo(disposeBag)
    
    mapView.rx.handleTapMarker { marker in
      
      self.present(self.askToStartTrip(marker: marker), animated: true, completion: nil)
      
      return false
    }
    
    mapView.rx.handleMarkerInfoWindow { marker in
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 60))
      label.textAlignment = .center
      label.textColor = UIColor.white
      label.font = UIFont.boldSystemFont(ofSize: 16)
      label.backgroundColor = UIColor.magenta
      label.text = marker.title
      return label
    }
    
    mapView.rx.handleTapMyLocationButton {
      print("Handle my location button")
      return false
    }
    
    mapView.rx.myLocation
      .subscribe(onNext: { location in
        if let l = location {
          print("My location: (\(l.coordinate.latitude), \(l.coordinate.longitude))")
          self.centerTheMap(lat: l.coordinate.latitude, lon: l.coordinate.longitude)
        } else {
          print("My location: nil")
        }
      })
      .addDisposableTo(disposeBag)
    
    mapView.rx.myLocation
      .subscribe(onNext: { location in
        if let l = location {
          print("My location: (\(l.coordinate.latitude), \(l.coordinate.longitude))")
        } else {
          print("My location: nil")
        }
      })
      .addDisposableTo(disposeBag)
    
    mapView.rx.selectedMarker.asDriver()
      .drive(onNext: { selected in
        if let marker = selected {
          print("Selected marker: \(marker.title ?? "") (\(marker.position.latitude), \(marker.position.longitude))")
        } else {
          print("Selected marker: nil")
        }
      })
      .addDisposableTo(disposeBag)
    
    do {
      let s0 = mapView.rx.selectedMarker.asObservable()
      let s1 = s0.skip(1)
      
      Observable.zip(s0, s1) { $0 }
        .subscribe(onNext: { (prev, cur) in
          if let marker = prev {
            marker.icon = UIImage(named: "locationPin")
          }
          if let marker = cur {
            marker.icon = UIImage(named: "locationPin")
          }
        })
        .addDisposableTo(disposeBag)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    
  }
  
  func deletePlaceFromCoreData(name: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ManagedPlace")
    fetchRequest.predicate = NSPredicate(format: "name == %@", name)
    
    let result = try? managedContext.fetch(fetchRequest)
    let resultData = result as! [ManagedPlace]
    
    for object in resultData {
      managedContext.delete(object)
   
      placeObjects = self.placeObjects.filter { $0 != object }
    }

    do {
      try managedContext.save()
      print("saved!")
    } catch let error as NSError  {
      print("Could not save \(error), \(error.userInfo)")
    } catch {
      
    }
  }
  
  func fetchPlaces() -> [NSManagedObject] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return []
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ManagedPlace")
    
    do {
      let places = try managedContext.fetch(fetchRequest)
      
      return places

    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return []
    }

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "buildTripSegue" {
      let destinationVC = segue.destination as! TripViewController
    }
  }
  
  @IBAction func addAPlaceTouched(_ sender: Any) {
    presentAutocomplete()
  }
  
  @IBAction func letsBeginTouched(_ sender: Any) {
    
    presentAutocomplete()
    
    getStartedView.isHidden = true
  }
  
  @IBAction func makeTripButtonTouched(_ sender: Any) {
    
    performSegue(withIdentifier: "buildTripSegue", sender: nil)
    
  }
  
  func presentAutocomplete() {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
  }
  
  func addMarkerToMap(name: String, address: String, latitude: Double, longitude: Double) {
    let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let marker = GMSMarker(position: position)
    marker.title = name
    marker.icon = UIImage(named: "locationPin")
    marker.snippet = address
    marker.map = mapView
    
    centerTheMap(lat: latitude, lon: longitude)
  }
  
  func addMarkersToMap(places: [NSManagedObject]) {
    for place in places {
      let latitude = place.value(forKey: "latitude") as! Double
      let longitude = place.value(forKey: "longitude") as! Double
      let name = place.value(forKey: "name") as! String
      let address = place.value(forKey: "address") as! String
      
      addMarkerToMap(name: name, address: address, latitude: latitude, longitude: longitude)
    }
  }
  
  func centerTheMap(lat : Double, lon: Double) {
    let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    
    let camera = GMSCameraPosition.camera(withLatitude: center.latitude, longitude: center.longitude, zoom: 14, bearing: 30, viewingAngle: 45)
    mapView.camera = camera
  }
  
  func highlightStartingPoint(latitude: Double, longitude: Double) {
    let circle = GMSCircle()
    circle.title = "Circle"
    circle.radius = 200
    circle.isTappable = true
        circle.position = CLLocationCoordinate2DMake(latitude, longitude)
    circle.fillColor = UIColor.green.withAlphaComponent(0.2)
    circle.strokeColor = UIColor.green.withAlphaComponent(0.8)
    circle.strokeWidth = 4
    circle.map = mapView
  }
  
  func askToStartTrip(marker: GMSMarker) -> UIAlertController {
    let alertController = UIAlertController(title: marker.title, message: "Add this place to the trip?", preferredStyle: UIAlertControllerStyle.alert)
    
    let cancelAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
      print("Remove from \(String(describing: marker.title)) from map.")
      marker.map = nil
      
      self.deletePlaceFromCoreData(name: marker.title!)
      
    }
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
      print("OK")
      //do nothing
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }
  
  @IBAction func clearTripTouched(_ sender: Any) {
    
    mapView.clear()
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ManagedPlace")
    
    let result = try? managedContext.fetch(fetchRequest)
    let resultData = result as! [ManagedPlace]
    
    for object in resultData {
      managedContext.delete(object)
      
      placeObjects = self.placeObjects.filter { $0 != object }
    }
    
    do {
      try managedContext.save()
      print("saved!")
    } catch let error as NSError  {
      print("Could not save \(error), \(error.userInfo)")
    } catch {
      
    }
    
  }
  
  
  //Location manager 
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      centerTheMap(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
  }
  
}

extension PlacesViewController: GMSAutocompleteViewControllerDelegate {
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    dismiss(animated: true, completion: {
      
      let newPlace = Place(place: place)
      let marker = newPlace.marker
      marker.map = self.mapView
      
      newPlace.savePlace()
      
      self.centerTheMap(lat: marker.position.latitude, lon: marker.position.longitude)
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



