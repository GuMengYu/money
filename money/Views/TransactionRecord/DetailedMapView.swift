/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A map view configured for this app.
*/

import MapKit
import SwiftUI

#if os(iOS)
  private typealias ViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
  private typealias ViewControllerRepresentable = NSViewControllerRepresentable
#endif

struct DetailedMapView: ViewControllerRepresentable {
  #if os(iOS)
    typealias ViewController = UIViewController
  #elseif os(macOS)
    typealias ViewController = NSViewController
  #endif

  var location: CLLocation
  var distance: Double = 1000
  var pitch: Double = 0
  var heading: Double = 0
  var topSafeAreaInset: Double
  var title: String? = "位置"

  class Controller: ViewController {
    var mapView: MKMapView {
      guard let tempView = view as? MKMapView else {
        fatalError("View could not be cast as MapView.")
      }
      return tempView
    }

    // 用于跟踪当前添加的标记点
    var currentAnnotation: MKPointAnnotation?

    override func loadView() {
      let mapView = MKMapView()
      view = mapView
      #if os(iOS)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      #elseif os(macOS)
        view.autoresizingMask = [.width, .height]
      #endif

      let configuration = MKStandardMapConfiguration(
        elevationStyle: .realistic, emphasisStyle: .default)
        configuration.pointOfInterestFilter = .includingAll
      configuration.showsTraffic = false
      mapView.preferredConfiguration = configuration
      mapView.isZoomEnabled = false
      mapView.isPitchEnabled = false
      mapView.isScrollEnabled = false
      mapView.isRotateEnabled = false
      mapView.showsCompass = false

      // 创建标记点
      let annotation = MKPointAnnotation()
      mapView.addAnnotation(annotation)
      currentAnnotation = annotation

      // 自定义标记点外观
      #if os(iOS)
        mapView.register(
          MKMarkerAnnotationView.self,
          forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
      #endif
    }
  }

  #if os(iOS)
    func makeUIViewController(context: Context) -> Controller {
      Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
      update(controller: controller)
    }
  #elseif os(macOS)
    func makeNSViewController(context: Context) -> Controller {
      Controller()
    }

    func updateNSViewController(_ controller: Controller, context: Context) {
      update(controller: controller)
    }
  #endif

  func update(controller: Controller) {
    #if os(iOS)
      controller.additionalSafeAreaInsets.top = topSafeAreaInset
    #endif

    // 设置地图相机位置
    controller.mapView.camera = MKMapCamera(
      lookingAtCenter: location.coordinate,
      fromDistance: distance,
      pitch: pitch,
      heading: heading
    )

    // 更新标记点位置和标题
    if let annotation = controller.currentAnnotation {
      annotation.coordinate = location.coordinate
      annotation.title = title
    }
  }
}

struct DetailedMapView_Previews: PreviewProvider {
  static var previews: some View {
    DetailedMapView(
      location: CLLocation(latitude: 37.335_690, longitude: -122.013_330), topSafeAreaInset: 0)
  }
}
