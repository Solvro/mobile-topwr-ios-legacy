import SwiftUI
import MapKit

struct DetailsMapView: View {
    #warning("TODO: Implement our normal Map with buildings and pins")
    let lat: CGFloat
    let lon: CGFloat
    let latDelta: CGFloat
    let lonDelta: CGFloat
    
    @State var region: MKCoordinateRegion
    
    public init(
        lat: Float?,
        lon: Float?,
        latDelta: CGFloat = 0.003,
        lonDelta: CGFloat = 0.003
    ) {
        self.lat = CGFloat(lat ?? 51.108046)
        self.lon = CGFloat(lon ?? 17.059665)
        self.latDelta = latDelta
        self.lonDelta = lonDelta
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: CGFloat(lat ?? 51.108046),
                longitude: CGFloat(lon ?? 17.059665)
            ),
            span: MKCoordinateSpan(
                latitudeDelta: latDelta,
                longitudeDelta: lonDelta
            )
        )
    }

    var body: some View {
        Map(coordinateRegion: $region)
    }
}
