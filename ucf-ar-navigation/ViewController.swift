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
	
	
	/// example path
	var coords: [CLLocationCoordinate2D] = [
		-- REPLACE WITH PATH OF COORDINATES --
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
		
		let source = 28.602184 ~ -81.200129
		let destination = 28.597187 ~ -81.199963
		
		addRoute(from: source, to: destination)
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
