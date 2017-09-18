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

class PlacesViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  
  let disposeBag = DisposeBag()
  let locationManager = CLLocationManager()
  
  var places : [Place] = [] {
    didSet {
      if places.count > 0 {
        self.title = "Where To Next?"
      } else {
        self.title = "Where To?"
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
  
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
            marker.icon = #imageLiteral(resourceName: "locationPin")
          }
          if let marker = cur {
            marker.icon = #imageLiteral(resourceName: "locationPin")
          }
        })
        .addDisposableTo(disposeBag)
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
    centerTheMap(lat: 40.7416089 , lon: -73.9931664)
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToTripSegue" {
//      let destinationVC = segue.destination as! TripViewController
//      destinationVC.placesArray = places
    }
  }
  
  @IBAction func addAPlaceTouched(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
  }
  
  
  @IBAction func makeTripButtonTouched(_ sender: Any) {
    
    performSegue(withIdentifier: "goToTripSegue", sender: nil)
  }
  
  
  func centerTheMap(lat : Double, lon: Double) {
    let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    
    let camera = GMSCameraPosition.camera(withLatitude: center.latitude, longitude: center.longitude, zoom: 14, bearing: 30, viewingAngle: 45)
    mapView.camera = camera
  }
  
  func highlightStartingPoint() {
    let circle = GMSCircle()
    circle.title = "Circle"
    circle.radius = 200
    circle.isTappable = true
    circle.position = (places.first?.marker.position)!
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
      
      self.places = self.places.filter { $0.marker != marker }
      
    }
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
      print("OK")
      //do nothing
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    return alertController
  }
  
}

extension PlacesViewController: GMSAutocompleteViewControllerDelegate {
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    dismiss(animated: true, completion: {
      
      let place = Place(place: place)
      let marker = place.marker
      marker.map = self.mapView
      
      self.places.append(place)
      
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



