//
//  PlaceDetailsViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlaceDetailsViewController: UIViewController, GMSMapViewDelegate{
  
  var placeID: String? = ""
  var place : GMSPlace?
  let placesClient = GMSPlacesClient()
  
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var openNowLabel: UILabel!
  @IBOutlet var placeImage: UIImageView!
  @IBOutlet var phoneNumberButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if placeID != "" {
      prepareTheView()
    }
    
  }
  
  func getPlaceByID(placeID: String) -> GMSPlace {
    placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
      if let error = error {
        print("lookup place id query error: \(error.localizedDescription)")
        return
      }
      
      guard let place = place else {
        print("No place details for \(String(describing: self.placeID))")
        return
      }
      
      
    })
    
    return place!
  }
  
  func prepareTheView() {
    let place = getPlaceByID(placeID: placeID!)
    
    title = place.name
    addressLabel.text = place.formattedAddress
    phoneNumberButton.setTitle(place.phoneNumber, for: .normal)
    
    loadFirstPhotoForPlace(placeID: place.placeID)
    
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
    marker.title = place.name
    marker.icon = UIImage(named: "locationPin")
    marker.map = self.mapView
    
    
    if place.openNowStatus.rawValue == 2 {
      self.openNowLabel.text = "OPEN"
      self.openNowLabel.textColor = UIColor(hue: 0.2778, saturation: 0.93, brightness: 0.62, alpha: 1.0)
    } else {
      self.openNowLabel.text = "CLOSED"
      self.openNowLabel.textColor = UIColor.red
    }
    
    
    if let center : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude) {
      let camera = GMSCameraPosition.camera(withLatitude: (center?.latitude)!, longitude: (center?.longitude)!, zoom: 16, bearing: 30, viewingAngle: 45)
      self.mapView.camera = camera
      
    }
  }
  
  func loadFirstPhotoForPlace(placeID: String) {
    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
      if let error = error {
        // TODO: handle the error.
        print("Error: \(error.localizedDescription)")
      } else {
        if let firstPhoto = photos?.results.first {
          self.loadImageForMetadata(photoMetadata: firstPhoto)
        }
      }
    }
  }
  
  func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
    GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
      (photo, error) -> Void in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      } else {
        self.placeImage.image = photo
      }
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  @IBAction func phoneNumberButtonTouched(_ sender: Any) {
    
    if let number = place?.phoneNumber {
      makeCall(phoneNumber: number)
    }
    
  }
  
  func makeCall(phoneNumber: String) {
    let formattedNumber = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
    let phoneUrl = "tel://\(formattedNumber)"
    let url:NSURL = NSURL(string: phoneUrl)!
    
    if #available(iOS 10, *) {
      UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.openURL(url as URL)
    }
  }
  
  
  @IBAction func shareThisPlaceTouched(_ sender: Any) {
    let place = Place(place: getPlaceByID(placeID: placeID!))
    
    shareThePlace(place: place)
  }
  
  func shareThePlace(place: Place) {
    
    let activityVC = UIActivityViewController(activityItems: place.makeShareable(), applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = self.view
    
    self.present(activityVC, animated: true, completion: nil)
  }
  
  
}

