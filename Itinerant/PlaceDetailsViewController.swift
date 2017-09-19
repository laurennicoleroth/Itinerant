//
//  PlaceDetailsViewController.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps

class PlaceDetailsViewController: UIViewController, GMSMapViewDelegate{
  
  var place: Place?
  @IBOutlet var placeImageView: UIImageView!
  @IBOutlet var placeName: UILabel!
  @IBOutlet var placeRating: UILabel!
//  @IBOutlet var mapView: GMSMapView!
  @IBOutlet var address: UILabel!
  @IBOutlet var starRating: UIImageView!
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    placeName.numberOfLines = 3
    
    if let place = place {
      
      //Set navigation title
      self.navigationItem.title = place.name
      
      //Set place details
      placeName.text = place.name
      placeRating.text = "\(place.rating)"
//      starRating.image = StarRating.rating(place.rating)
      
      if let address = place.address {
        self.address.text = address
      }
      
      
//      if (place.photo == nil) {
//        let params : [String:AnyObject] = ["maxwidth" : 500 as AnyObject,
//                                           "photoreference": "\(place.photoReference)" as AnyObject,
//                                           "key" : Constants.Keys.GoogleKey as AnyObject]
//        
//        Alamofire.request(.GET, Constants.Url.GoogleApiPlaceSearchPhoto, parameters: params ).response{ (request, response, dataIn, error) in
//          
//          
//          //get back to main thread
//          DispatchQueue.main.async { [unowned self] in
//            if let imageData = dataIn {
//              self.placeImageView.image = UIImage(data: imageData)
//            }
//          }
//        }
//      }
//      else{
//        placeImageView.image = place.photo
//      }
      
      
      //Display map
      let coordinates : CLLocationCoordinate2D = CLLocationCoordinate2DMake(place.latitude, place.longitude)
      
      let camera : GMSCameraPosition = GMSCameraPosition(target:coordinates, zoom:15, bearing:0, viewingAngle:0)
      
      self.mapView.camera = camera
      self.mapView.myLocationEnabled = true
      self.mapView.delegate = self;
      
      let marker : GMSMarker = GMSMarker()
      marker.position = coordinates
      marker.title = place.name
      marker.icon =  UIImage(named:"locationPin")
      marker.map = self.mapView;
      
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //customize navigation bar
    self.navigationController?.navigationBar.barTintColor = UIColor.white
    self.navigationController?.navigationBar.tintColor = UIColor.gray
  }
  
  
  @IBAction func loadWebsite(_ sender: AnyObject) {
    
//    let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: type(of: self)))
//    if let webVC = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
//      
//      if let place = place {
//        webVC.name = place.name
//        webVC.url = place.website
//        self.navigationController?.pushViewController(webVC, animated: true)
//      }
//    }
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

