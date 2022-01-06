import SwiftUI
import MapKit

struct DepartmentMapView: View {
    #warning("TODO: Departments coordinates")
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.108046, longitude: 17.059665),
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    )

    var body: some View {
        Map(coordinateRegion: $region)
    }
}
