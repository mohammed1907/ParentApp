//
//  MapDetailsViewController.swift
//  ParentApp
//
//  Created by Youm7 on 8/10/20.
//  Copyright © 2020 Test.iosapp. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GeoFire
class MapDetailsViewController: UIViewController,GMSMapViewDelegate {
    @IBOutlet weak var viewForGoogleMap: UIView!
     var firstload = false
      var mappView:GMSMapView?
      var marker = GMSMarker()
      let geocoder = GMSGeocoder()
      var sfQuery: GFQuery!
      var locationManager = CLLocationManager()
      var currentLocation: CLLocation!
      var markerView = UIImageView(image: UIImage(named: "Map_TabBarIcon_color"))
    var finalcoordinates = CLLocationCoordinate2D()
      let geofireRef = Database.database().reference().child("users")
    var users: User!
    override func viewDidLoad() {
        super.viewDidLoad()
   checkLocationPermission()
        // Do any additional setup after loading the view.
    }
    func checkLocationPermission()  {
         if CLLocationManager.locationServicesEnabled() {
             switch CLLocationManager.authorizationStatus() {
             case .notDetermined, .restricted, .denied:
                 print("No access")
                 locationManager.requestWhenInUseAuthorization()
             case .authorizedAlways, .authorizedWhenInUse:
                 print("Access")
                 currentLocation = locationManager.location
                 creategooglemap()
             }
         } else {
             print("Location services are not enabled")
         }
     }
    func  creategooglemap(){
          let geoFire = GeoFire(firebaseRef: self.geofireRef)


          geoFire.getLocationForKey("\(users.key!)") { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \(self.users.name!): ")
             
            } else if (location != nil) {
                print("Location for \(self.users.name!) is [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude, longitude:location!.coordinate.longitude, zoom: 16.0)
                
                self.mappView = GMSMapView.map(withFrame: self.viewForGoogleMap.bounds, camera: camera)
                
                self.mappView?.center = self.viewForGoogleMap.center
                self.mappView?.settings.myLocationButton = true
                self.mappView?.isMyLocationEnabled = true
                self.mappView?.delegate = self
                self.mappView?.padding = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
                self.viewForGoogleMap.addSubview(self.mappView!)
                
                // Creates a marker in the center of the map.
                self.marker.iconView = self.markerView
                   self.marker.position = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                self.marker.map = self.mappView
               
            } else {
              print("GeoFire does not contain a location for \"firebase-hq\"")
            }
          }
        
          marker.map = mappView
          
      }
  

}
