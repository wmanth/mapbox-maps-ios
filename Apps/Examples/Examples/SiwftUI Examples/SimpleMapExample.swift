import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct SimpleMapExample: View {
    @State var camera = CameraState(center: .helsinki, zoom: 12)
    var body: some View {
        MapboxView(camera: $camera)
            .styleURI(.streets, darkMode: .dark)
            .edgesIgnoringSafeArea(.all)
            .cameraDebugOverlay(alignment: .bottom, camera: $camera)
    }
}

@available(iOS 14.0, *)
struct SimpleMapExample_Previews: PreviewProvider {
    static var previews: some View {
        SimpleMapExample()
    }
}
