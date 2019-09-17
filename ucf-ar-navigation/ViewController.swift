//
//  ViewController.swift
//  ucf-ar-navigation
//
//  Created by Jacob Caraballo on 9/15/19.
//  Copyright © 2019 Zogo. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit
import MapKit
import ARKit
import ARKit_CoreLocation


/// JC: Custom operator to simplify initialization of coordinates
infix operator ~
func ~(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) -> CLLocationCoordinate2D {
	return CLLocationCoordinate2D(latitude: lat, longitude: lon)
}


class ViewController: UIViewController {
	
	var sceneLocationView = SceneLocationView()
	
	let zFarInput = UITextField()
	let fogInput = UITextField()
	
	let home = 28.357021 ~ -81.384033
	let destination = 28.345967 ~ -81.366025
	
	/// example path
	var coords = [
	
		28.357230 ~ -81.384123,
		28.357305 ~ -81.383933,
		28.357403 ~ -81.383893,
		28.357619 ~ -81.383950,
		28.358117 ~ -81.384157,
		28.358458 ~ -81.384250,
		28.358714 ~ -81.384275,
		28.358742 ~ -81.383450,
		28.358852 ~ -81.383081,
		28.358916 ~ -81.382935,
		28.359171 ~ -81.382434,
		28.359238 ~ -81.382222,
		28.359310 ~ -81.381890,
		28.359393 ~ -81.381243,
		28.359430 ~ -81.381038,
		28.359508 ~ -81.380817,
		28.359607 ~ -81.380635,
		28.360932 ~ -81.379444,
		28.361057 ~ -81.379389,
		28.361215 ~ -81.379382,
		28.361372 ~ -81.379422,
		28.361444 ~ -81.379463,
		28.361621 ~ -81.379662,
		28.361763 ~ -81.379940,
		28.361872 ~ -81.380196,
		28.361972 ~ -81.380509,
		28.362035 ~ -81.380901,
		28.362061 ~ -81.381501,
		28.362868 ~ -81.381630,
		28.362954 ~ -81.381594,
		28.363262 ~ -81.381530,
		28.363546 ~ -81.381433,
		28.364435 ~ -81.380986,
		28.364336 ~ -81.380739,
		28.364257 ~ -81.380520,
		28.364134 ~ -81.380191,
		28.364050 ~ -81.379956,
		28.363944 ~ -81.379674,
		28.363859 ~ -81.379449,
		28.363769 ~ -81.379195,
		28.363674 ~ -81.378942,
		28.363579 ~ -81.378695,
		28.363480 ~ -81.378424,
		28.363380 ~ -81.378158,
		28.363279 ~ -81.377885,
		28.363228 ~ -81.377706,
		28.363132 ~ -81.377451,
		28.363038 ~ -81.377196,
		28.362985 ~ -81.377058,
		28.362876 ~ -81.376758,
		28.362772 ~ -81.376487,
		28.362677 ~ -81.376224,
		28.362574 ~ -81.375951,
		28.362486 ~ -81.375701,
		28.362349 ~ -81.375337,
		28.362215 ~ -81.374979,
		28.362003 ~ -81.374405,
		28.361868 ~ -81.374011,
		28.361789 ~ -81.373756,
		28.361679 ~ -81.373333,
		28.361602 ~ -81.373039,
		28.361554 ~ -81.372777,
		28.361471 ~ -81.372301,
		28.361442 ~ -81.372040,
		28.361381 ~ -81.371428,
		28.361367 ~ -81.371026,
		28.361369 ~ -81.370452
		
	]
	
	
	/// returns the users current coordinate location within the world
	var currentLocation: CLLocationCoordinate2D? {
		return sceneLocationView.me?.location.coordinate
	}
	
	
	/// returns the users current position within the scene
	var currentPosition: SCNVector3? {
		return sceneLocationView.me?.position
	}
    
	
	override func viewDidLoad() {
		super.viewDidLoad()
				
		setupScene()
		setupButton()
		setupInputs()
		
	}
	
	func setupScene() {
		
		// the limit at which contents will be loaded into the scene
		sceneLocationView.zFar = 1000
		
		// the radius at which the scene will begin to fade out
		sceneLocationView.sceneRadius = 30
		
		
		sceneLocationView.run()
		sceneLocationView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(sceneLocationView)
		
		
		NSLayoutConstraint.activate([
			sceneLocationView.widthAnchor.constraint(equalTo: view.widthAnchor),
			sceneLocationView.heightAnchor.constraint(equalTo: view.heightAnchor),
			sceneLocationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			sceneLocationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		
	}
	
	func setupInputs() {
		
		zFarInput.translatesAutoresizingMaskIntoConstraints = false
		zFarInput.text = "\(Int(sceneLocationView.zFar))"
		zFarInput.keyboardType = .numberPad
		zFarInput.delegate = self
		zFarInput.backgroundColor = UIColor(white: 0, alpha: 0.9)
		zFarInput.textAlignment = .center
		zFarInput.contentVerticalAlignment = .center
		zFarInput.layer.cornerRadius = 5
		view.addSubview(zFarInput)
		
		fogInput.translatesAutoresizingMaskIntoConstraints = false
		fogInput.text = "\(Int(sceneLocationView.sceneRadius))"
		fogInput.keyboardType = .numberPad
		fogInput.delegate = self
		fogInput.backgroundColor = UIColor(white: 0, alpha: 0.9)
		fogInput.textAlignment = .center
		fogInput.contentVerticalAlignment = .center
		fogInput.layer.cornerRadius = 5
		view.addSubview(fogInput)
		
		
		let padding: CGFloat = 10
		
		NSLayoutConstraint.activate([
			
			zFarInput.heightAnchor.constraint(equalToConstant: 50),
			zFarInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35, constant: -(padding + padding / 2)),
			zFarInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
			zFarInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			
			fogInput.heightAnchor.constraint(equalToConstant: 50),
			fogInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35, constant: -(padding + padding / 2)),
			fogInput.leadingAnchor.constraint(equalTo: zFarInput.trailingAnchor, constant: padding),
			fogInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
		
		])
		
	}
	
	
	func setupButton() {
		
		let button = UIButton()
		button.backgroundColor = .black
		button.layer.cornerRadius = 5
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Reload", for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
		button.sizeToFit()
		view.addSubview(button)
		
		button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.30, constant: -10),
			button.heightAnchor.constraint(equalToConstant: 50),
			button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
		
		])
		
	}
	
	func setBoundsFromInput() {
		guard let zFar = Int(zFarInput.text!), let radius = Int(fogInput.text!) else { return }
		sceneLocationView.zFar = CLLocationDistance(zFar)
		sceneLocationView.sceneRadius = CGFloat(radius)
	}
	
	@objc func buttonPressed() {
		
		setBoundsFromInput()
		loadExampleRouteCustom()
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	
}


// MARK: TextField Delegate
extension ViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
}


// MARK: Examples
extension ViewController {
	
	/// Loads a custom route set by the insertion of the specified coordinates above.
	func loadExampleRouteCustom() {
		
		// insert the current location of the user into the beginning of the array, so that the path begins at the users location.
		// not necessary if array already contains the current location
		var coords = self.coords
		if let currentLocation = self.currentLocation {
			coords.insert(currentLocation, at: 0)
		}
		
		// add the route to the scene, using the coordinates array
		sceneLocationView.addRoute(with: coords)
		
	}
	
	
	/// Loads a route by requesting directions as a 'walking route' from Apple Maps.
	func loadExampleRouteAppleMaps() {
		addRoute(from: home, to: destination)
	}
	
}


// MARK: Adding Nodes
extension ViewController {
	
	/// add route by requesting walking directions from Apple Maps
	func addRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
		let request = MKDirections.Request()
		request.transportType = .walking
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
		request.requestsAlternateRoutes = false
		
		let directions = MKDirections(request: request)
		directions.calculate { (response, _) in
			guard let response = response else { return }
			self.sceneLocationView.addRoutes(routes: response.routes)
		}
	}
	
	
	/// adds a pin to the given coordinate
	func addPin(to coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) -> LocationAnnotationNode {
		let location = CLLocation(coordinate: coordinate, altitude: altitude)
		let image = UIImage(named: "pin")!
		let annotationNode = LocationAnnotationNode(location: location, image: image)
		sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
		return annotationNode
	}
	
	
	/// adds a pin at the users current location
	func addPinAtCurrentLocation() -> LocationAnnotationNode {
		let node = LocationAnnotationNode(location: nil, image: UIImage(named: "pin")!)
		sceneLocationView.addLocationNodeForCurrentPosition(locationNode: node)
		return node
	}
	
}
