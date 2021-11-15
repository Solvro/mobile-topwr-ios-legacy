import Foundation
import Common
import MapKit

public struct MapCoordinator {
    public init(){}

    func parseGeoJSON() -> [MKOverlay] {
        guard let url = Bundle.module.url(forResource: "buildingsPwr", withExtension: "json") else {
            #warning("TODO: Error handler")
            return []
        }
    
        var geoJson = [MKGeoJSONObject]()
        var overlays = [MKOverlay]()
        var collection: Collection? = nil
        
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
            collection = try JSONDecoder().decode(Collection.self, from: data)
            
        } catch {
            #warning("TODO: Error handler")
        }
        
        for (index, item) in geoJson.enumerated() {
            if let feature = item as? MKGeoJSONFeature {
                for geo in feature.geometry {
                    geo.subtitle = collection?.features[safe: index]?.properties?.id
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

struct Collection: Decodable {
    let type: String
    let features: [Feature]
}

struct Feature: Decodable {
    let type: String
    let properties: Properties?
}

struct Properties: Decodable {
    let id: String?
}
