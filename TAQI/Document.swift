//
//  Document.swift
//  Timeline
//
//  Created by Samuel Lichlyter on 11/8/18.
//  Copyright © 2018 Samuel Lichlyter. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    var paths: [Path] = []
    var locations: [Location] = []
    var package: FileWrapper?
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        
        if
            let json = try? JSONSerialization.jsonObject(with: contents as! Data, options: []),
            let dictionary = json as? [String: Any] {
                if let locations = dictionary["locations"] as? [Any] {
                    let validLocations = locations.compactMap { Location(google: $0 as! [String : Any])}
                    self.locations = validLocations
                    generatePaths(locations: validLocations)
                    // Google updated file structure so now they no longer need to be reversed (older files will show incorrect results)
                }
        } else { return }
    }
    
    func generatePaths(locations: [Location]) {
        
        if locations.count == 0 {
            return
        }
        
        var paths: [Path] = []
        var pathLocations: [Location] = []
        pathLocations.append(locations[0])
        
        for location in locations {
            let calendar = Calendar.current
            let lastTimestamp = pathLocations.last!.timestamp!
            let fifteenMinutes = calendar.date(byAdding: .minute, value: 15, to: lastTimestamp)
            if location.timestamp! < fifteenMinutes! {
                pathLocations.append(location)
                print("adding to old path")
            } else {
                if pathLocations.count > 2 {
                    let path = Path(locations: pathLocations)
                    paths.append(path)
                }
                pathLocations.removeAll()
                pathLocations.append(location)
                print("making new path")
            }
            
            // if last location, make a path
            if location == locations.last! {
                print("********* Saving last path *********")
                if pathLocations.count > 2 {
                    let path = Path(locations: pathLocations)
                    paths.append(path)
                }
            }
        }
        
        print("Num Paths: \(paths.count)")
        self.paths = paths
    }
}