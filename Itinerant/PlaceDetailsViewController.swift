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
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    placeNameLabel.text = place?.name
    addressLabel.text = place?.address
    
    let center = CLLocationCoordinate2D(latitude: (place?.latitude)!, longitude: (place?.longitude)!)
    
    let camera = GMSCameraPosition.camera(withLatitude: center.latitude, longitude: center.longitude, zoom: 14, bearing: 30, viewingAngle: 45)
    mapView.camera = camera
    
    let marker = place?.marker
    marker?.map = mapView
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

