//
//  PolylineNode.swift
//  ARKit+CoreLocation
//
//  Created by Ilya Seliverstov on 11/08/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import SceneKit
import MapKit

/// A block that will build an SCNBox with the provided distance.
/// Note: the distance should be aassigned to the length
public typealias BoxBuilder = (_ distance: CGFloat) -> SCNBox


/// JC: Struct to customize the polyline
public struct PolylineAttributes {
	
	/// JC: Sets the width of the polyline.
	public var width: CGFloat = 1.0
	
	/// JC: Sets the height of the polyline.
	public var height: CGFloat = 0.2
	
	/// JC: Sets the length offset of the polyline. Consecutive lines will be separated by this offset.
	public var lengthOffset: CGFloat = 0
	
	/// JC: Sets the chamfer radius of the polyline.
	public var chamferRadius: CGFloat = 0
	
	/// JC: Sets the blending color of the polyline. May not always produce an exact color, since the polyline screen blends with the world in order to fade out the line at a distance.
	public var blendColor: UIColor = .green
	
}


/// A Node that is used to show directions in AR-CL.
public class PolylineNode: LocationNode {
    public private(set) var locationNodes = [LocationNode]()

    public let polyline: MKPolyline
    public let altitude: CLLocationDistance
    public let boxBuilder: BoxBuilder
	

    /// Creates a `PolylineNode` from the provided polyline, altitude (which is assumed to be uniform
    /// for all of the points) and an optional SCNBox to use as a prototype for the location boxes.
    ///
    /// - Parameters:
    ///   - polyline: The polyline that we'll be creating location nodes for.
    ///   - altitude: The uniform altitude to use to show the location nodes.
    ///   - boxBuilder: A block that will customize how a box is built.
	public init(polyline: MKPolyline, altitude: CLLocationDistance, boxBuilder: @escaping BoxBuilder) {
        self.polyline = polyline
        self.altitude = altitude
		self.boxBuilder = boxBuilder

        super.init(location: nil)

        contructNodes()
    }
	
	
	/// JC: Creates a `PolylineNode` using the given polyline, altitude, and attributes.
	convenience init(polyline: MKPolyline, altitude: CLLocationDistance, attributes: PolylineAttributes = PolylineAttributes()) {
		self.init(polyline: polyline, altitude: altitude, boxBuilder: { (distance) -> SCNBox in
			let box = SCNBox(width: attributes.width, height: attributes.height, length: distance - attributes.lengthOffset, chamferRadius: attributes.chamferRadius)
			box.firstMaterial?.diffuse.contents = UIColor.black
			box.firstMaterial?.reflective.contents = attributes.blendColor
			box.firstMaterial?.blendMode = .screen
			return box
		})
	}

	required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
	}

}

// MARK: - Implementation

private extension PolylineNode {

//    struct Constants {
//        static let defaultBuilder: BoxBuilder = { (distance) -> SCNBox in
//			let box = SCNBox(width: 1, height: 0.2, length: distance - 1, chamferRadius: 0)
//			box.firstMaterial?.diffuse.contents = UIColor.black
//			box.firstMaterial?.reflective.contents = blendColor
//			box.firstMaterial?.blendMode = .screen
//            return box
//        }
//    }

    /// This is what actually builds the SCNNodes and appends them to the
    /// locationNodes collection so they can be added to the scene and shown
    /// to the user.  If the prototype box is nil, then the default box will be used
    func contructNodes() {
        let points = polyline.points()

        for i in 0 ..< polyline.pointCount - 1 {
            let currentLocation = CLLocation(coordinate: points[i].coordinate, altitude: altitude)
            let nextLocation = CLLocation(coordinate: points[i + 1].coordinate, altitude: altitude)

            let distance = currentLocation.distance(from: nextLocation)

            let box = boxBuilder(CGFloat(distance))
            let boxNode = SCNNode(geometry: box)
            boxNode.removeFlicker()

            let bearing = -currentLocation.bearing(between: nextLocation)

            boxNode.pivot = SCNMatrix4MakeTranslation(0, 0, 0.5 * Float(distance))
            boxNode.eulerAngles.y = Float(bearing).degreesToRadians

            let locationNode = LocationNode(location: currentLocation)
            locationNode.addChildNode(boxNode)

            locationNodes.append(locationNode)
        }
    }

}
