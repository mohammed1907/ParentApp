//
//  RegisterViewController.swift
//  HoldenKnight
//
//  Created by Farghaly on 2/12/20.
//  Copyright © 2020 Test.iosapp. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GeoFire
protocol RefreshChildsDelegate: class {
    func refreshchilds()
}
class RegisterChildViewController: UIViewController,GMSMapViewDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fnameTF: FormTextField!
    @IBOutlet weak var emailTF: FormTextField!
    @IBOutlet weak var passwordTF: FormTextField!
    @IBOutlet weak var dateOfBirthView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var genderButton: DropdownButton!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dateOfBirthLaebl: UILabel!
      @IBOutlet weak var viewForGoogleMap: UIView!
    var kind: String = ""
    var timeStamp = Int64()
    weak var delegate: RefreshChildsDelegate?
    var firstload = false
    var mappView:GMSMapView?
    var marker = GMSMarker()
    let geocoder = GMSGeocoder()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var markerView = UIImageView(image: UIImage(named: "Map_TabBarIcon_color"))
  var finalcoordinates = CLLocationCoordinate2D()
    let geofireRef = Database.database().reference().child("users")
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dateOfBirthTapped(_:)))
        dateOfBirthView.addGestureRecognizer(tapGestureRecognizer)
        self.title = "New Account"
        genderButton.optionsData = ["male","female"]
        
        genderButton.selectionClosure = { (index, item) in
            self.genderButton.setTitle("Gender", for: .normal)
            self.genderLabel.text = item
        }
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
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 16.0)
        
        mappView = GMSMapView.map(withFrame: viewForGoogleMap.bounds, camera: camera)
        
        mappView?.center = self.viewForGoogleMap.center
        mappView?.settings.myLocationButton = true
        mappView?.isMyLocationEnabled = true
        mappView?.delegate = self
        mappView?.padding = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)
        self.viewForGoogleMap.addSubview(mappView!)
        
        marker.iconView = markerView
        
        marker.position = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)

        marker.map = mappView
        
    }
  
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        let circle = GMSCircle(position: marker.position, radius:10)
        circle.fillColor = .clear
        circle.strokeWidth = 2
        circle.strokeColor = .blue
        circle.map = mappView
       self.finalcoordinates = marker.position
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
      navigationController?.navigationBar.barTintColor = UIColor.maincolor
        
    }
    
    @IBAction func gotoLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func dateOfBirthTapped(_ sender:AnyObject){
        showDatePickerInAlert(title: "Date of Brith")
    }
    func showDatePickerInAlert(title: String) {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        //create datePicker and add it
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        datePicker.datePickerMode = .date
        //       datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18 , to: Date())
        
        
        datePicker.locale = Locale(identifier: "en_US")
        vc.view.addSubview(datePicker)
        alert.setValue(vc, forKey: "contentViewController")
        
        
        //add actions
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.timeStamp = Int64(datePicker.date.timeIntervalSince1970)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            print("llll\(datePicker.date)")
            self.dateOfBirthLaebl.text = formatter.string(from: datePicker.date) ///set action
            
        }))
        
        //present
        present(alert, animated: true, completion: nil)
    }
    func validate() -> Bool {
        var valid: Bool = true
        
        if (fnameTF.text?.isEmpty)! {
            fnameTF.showError(message: "Field can't be empty")
            valid = false
        }
        
        if (!((emailTF.text?.isValidEmail())!)) {
            emailTF.showError(message: "Enter valid email")
            valid = false
        }
        
        
        if (passwordTF.text?.isEmpty)! {
            passwordTF.showError(message: "Field can't be empty")
            valid = false
        }
        if (dateOfBirthLaebl.text?.isEmpty)! {
            showMessage(message: "Please select your Birthdate")
            valid = false
        }
        
        return valid
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if validate() {
            
            Auth.auth().createUser(withEmail: emailTF.text ?? "", password: passwordTF.text ?? "") { authResult, error in
                // [START_EXCLUDE]
                
                guard let user = authResult?.user, error == nil else {
                    self.showMessage(message: "\(error?.localizedDescription ?? "Error" )")
                    return
                }
                print("\(user.email!) created")
                
                guard let uid = authResult?.user.uid else {
                    return
                }
                
                //successfully authenticated user
                let ref = Database.database().reference()
                let usersReference = ref.child("users").child(uid)
                let values = ["name": self.fnameTF.text ?? "", "email": self.emailTF.text ?? ""]
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if let err = err {
                        print(err)
                        return
                    }
                    
                    print("Saved user successfully into Firebase db ")
                    let geoFire = GeoFire(firebaseRef: self.geofireRef)
                    let center = CLLocation(latitude: self.finalcoordinates.latitude, longitude: self.finalcoordinates.longitude)

                    geoFire.setLocation(center, forKey: "\(uid)") { (error) in
                      if (error != nil) {
                        print("An error occured: \(error)")
                      } else {
                        print("Saved location successfully!")
                         self.delegate?.refreshchilds()
                      }
                    }
                   
                    self.navigationController?.popViewController(animated: true)
                })
            }
            
            
            
        }
    }
    
}

extension RegisterChildViewController {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if firstload{
            var destinationLocation = CLLocation()
            destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
            let destinationCoordinate = destinationLocation.coordinate
            updateLocationoordinates(coordinates: destinationCoordinate)
            geocoder.reverseGeocodeCoordinate(destinationCoordinate) { response, error in
                //
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    if let places = response?.results() {
                        if let place = places.first {
                            
                            
                            if let lines = place.lines {
                           
                                    self.locationLabel.text = lines.first
//                                }
                            }
                            
                        } else {
                            print("GEOCODE: nil first in places")
                        }
                    } else {
                        print("GEOCODE: nil in places")
                    }
                }
            }
            
        }
        firstload = true
    }
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {

            CATransaction.begin()
            marker.position =  coordinates
            CATransaction.commit()
        
        
    }
}
