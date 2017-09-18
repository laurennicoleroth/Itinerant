//
//  RxGoogleMapsBridge.swift
//  Itinerant
//
//  Created by Lauren Nicole Roth on 9/18/17.
//  Copyright © 2017 Lauren Nicole Roth. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RxGoogleMaps
import RxCocoa
import RxSwift
import GooglePlaces

extension RxGMSMapViewDelegateProxy: GMSMapViewDelegate {
  
  public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    return self.didHandleTap(marker)
  }
  
  public func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    return self.markerInfoWindow(marker: marker)
  }
  
  public func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
    return self.markerInfoContents(marker: marker)
  }
  
  public func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    return self.didTapMyLocationButton()
  }
}

extension GoogleMaps.GMSMapView: RxGMSMapView {
  public var delegateWrapper: RxGMSMapViewDelegate? {
    get { return delegate as? RxGMSMapViewDelegate }
    set { delegate = newValue as? GMSMapViewDelegate }
  }
  
  public var cameraWrapper: RxGMSCameraPosition {
    get { return camera as RxGMSCameraPosition }
    set { camera = newValue as! GMSCameraPosition }
  }
  
  public var selectedMarkerWrapper: RxGMSMarker? {
    get { return selectedMarker }
    set { selectedMarker = newValue as? GMSMarker }
  }
  
  public func animateWrapper(to cameraPosition: RxGMSCameraPosition) {
    animate(to: cameraPosition as! GMSCameraPosition)
  }
  
  public var settingsWrapper: RxGMSUISettings {
    return settings as RxGMSUISettings
  }
  
}

extension Reactive where Base: GoogleMaps.GMSMapView {
  
  /**
   Wrapper of: mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
   */
  public var didChangePosition: ControlEvent<GMSCameraPosition> {
    return ControlEvent(events: didChangePositionWrapper.map { $0 as! GMSCameraPosition })
  }
  
  /**
   Wrapper of: mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
   */
  public var idleAtPosition: ControlEvent<GMSCameraPosition> {
    return ControlEvent(events: idleAtPositionWrapper.map { $0 as! GMSCameraPosition })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
   */
  public var didTapMarker: ControlEvent<GMSMarker> {
    return ControlEvent(events: didTapMarkerWrapper.map { $0 as! GMSMarker })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
   */
  public var didTapInfoWindow: ControlEvent<GMSMarker> {
    return ControlEvent(events: didTapInfoWindowWrapper.map { $0 as! GMSMarker })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker)
   */
  public var didLongPressInfoWindow: ControlEvent<GMSMarker> {
    return ControlEvent(events: didLongPressInfoWindowWrapper.map { $0 as! GMSMarker })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
   */
  public var didTapOverlay: ControlEvent<GMSOverlay> {
    return ControlEvent(events: didTapOverlayWrapper.map { $0 as! GMSOverlay })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker)
   */
  public var didCloseInfoWindow: ControlEvent<GMSMarker> {
    return ControlEvent(events: didCloseInfoWindowWrapper.map { $0 as! GMSMarker })
  }
  
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker)
   */
  public var didBeginDraggingMarker: ControlEvent<GMSMarker> {
    return ControlEvent(events: didBeginDraggingMarkerWrapper.map { $0 as! GMSMarker })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker)
   */
  public var didEndDraggingMarker: ControlEvent<GMSMarker> {
    return ControlEvent(events: didEndDraggingMarkerWrapper.map { $0 as! GMSMarker })
  }
  
  /**
   Wrapper of: func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker)
   */
  public var didDragMarker: ControlEvent<GMSMarker> {
    return ControlEvent(events: didDragMarkerWrapper.map { $0 as! GMSMarker })
  }
  
}

extension Reactive where Base: GoogleMaps.GMSMapView {
  
  public func handleTapMarker(_ closure: ((GMSMarker) -> (Bool))?) {
    if let c = closure {
      handleTapMarkerWrapper { c($0 as! GMSMarker) }
    } else {
      handleTapMarkerWrapper(nil)
    }
  }
  
  public func handleMarkerInfoWindow(_ closure: ((GMSMarker) -> (UIView?))?) {
    if let c = closure {
      handleMarkerInfoWindowWrapper { c($0 as! GMSMarker) }
    } else {
      handleMarkerInfoWindowWrapper(nil)
    }
  }
  
  public func handleMarkerInfoContents(_ closure: ((GMSMarker) -> (UIView?))?) {
    if let c = closure {
      handleMarkerInfoContentsWrapper { c($0 as! GMSMarker) }
    } else {
      handleMarkerInfoContentsWrapper(nil)
    }
  }
  
}

extension GoogleMaps.GMSUISettings: RxGMSUISettings { }

extension GoogleMaps.GMSCameraPosition: RxGMSCameraPosition { }

extension GoogleMaps.GMSOverlay: RxGMSOverlay { }

extension GoogleMaps.GMSMarker: RxGMSMarker { }

extension GoogleMaps.GMSCircle: RxGMSCircle { }

extension GoogleMaps.GMSPolyline: RxGMSPolyline { }

extension GoogleMaps.GMSPolygon: RxGMSPolygon { }

extension GoogleMaps.GMSGroundOverlay: RxGMSGroundOverlay { }
