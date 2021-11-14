import Foundation
import Common
import MapKit

public struct MapCoordinator {
    public init(){}

    func parseGeoJSON() -> [MKOverlay] {
        guard let url = Bundle.module.url(forResource: "buildingsPwr", withExtension: "json") else {
            fatalError("")
        }
    
        var geoJson = [MKGeoJSONObject]()
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
        } catch {
            
        }
        
        var overlays = [MKOverlay]()
        
        for item in geoJson {
            if let feature = item as? MKGeoJSONFeature {
                for geo in feature.geometry {
                    geo.title = "buildings"
                    if let polygon = geo as? MKPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
        return overlays
    }
}
