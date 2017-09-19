//
//  PlaceDetailsViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceDetailsViewController: UIViewController, GMSMapViewDelegate{
  
  var place: Place?
  
  @IBOutlet var placeNameLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var openNowLabel: UILabel!
  @IBOutlet var phoneNumberLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.title = "Place Details"
    
    placeNameLabel.text = place?.name
    addressLabel.text = place?.address
    phoneNumberLabel.text = place?.phoneNumber
    
    if place?.openNow == true {
      openNowLabel.text = "OPEN"
      openNowLabel.textColor = UIColor(hue: 0.2778, saturation: 0.93, brightness: 0.62, alpha: 1.0)
    } else {
      openNowLabel.text = "CLOSED"
      openNowLabel.textColor = UIColor.red
    }
    
    
    if let center : CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: (place?.latitude)!, longitude: (place?.longitude)!) {
      let camera = GMSCameraPosition.camera(withLatitude: (center?.latitude)!, longitude: (center?.longitude)!, zoom: 16, bearing: 30, viewingAngle: 45)
      mapView.camera = camera
      
      let marker = place?.marker
      marker?.map = mapView
    }
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  
  }
  
  @IBAction func shareThisPlaceTouched(_ sender: Any) {
    shareThePlace(place: place!)
  }
  
  func shareThePlace(place: Place) {
    
    let activityVC = UIActivityViewController(activityItems: place.makeShareable(), applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = self.view
    
    self.present(activityVC, animated: true, completion: nil)
  }
  
  
}

