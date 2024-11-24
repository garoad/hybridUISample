# UIKit 프로젝트에 SwiftUI 적용하는 예제
### 뷰 계층 구조
![hierarchy](https://github.com/user-attachments/assets/3b0f3a3d-b5ab-4277-a298-2d57f9a4bc8e)

### ViewModel
```swift
final class MapOverViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion = .init()
    @Published var searchResults = [MKMapItem]()
    
    @Published var selectItem: MKMapItem?
    @Published var selectPin: MKPointAnnotation?
…
  }
}
```
- ViewController 와 SwiftUIView 는 ViewModel 을 통해 이벤트와 자료를 주고 받는다.
- ObservableObject를 상속 받고 @Published 프로퍼티를 통해 이벤트를 동기화 한다.

### ViewController
```swift
final class MapOverViewController: UIViewController {
…
  private func setupUI() {
      …
      let overView = MapTouchView(frame: .zero)
      view.addSubview(overView)
      …       
      let hostingController = MapHostingViewController(rootView: MapOverView().environmentObject(viewModel))
      addChild(hostingController)
      view.addSubview(hostingController.view)
      …
    }
…
  private func observe() {
    viewModel.$selectItem
        .receive(on: DispatchQueue.main).sink { [weak self] selectedItem in
            guard let self = self, let selectedItem = selectedItem else { return }
            let detailVC = MapItemViewController(selectedItem)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }.store(in: &cancellables)
    viewModel.$searchResults
        .receive(on: DispatchQueue.main).sink { [weak self] results in
            self?.updateMapAnnotations(results)
        }.store(in: &cancellables)
  }
…
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      if let annotation = view.annotation as? MKPointAnnotation {
          viewModel.selectPin = annotation
      }
  }
…
}
```
- ViewController는 viewModel을 SwifUIView에 environmentObject로 전달
- viewModel에 선언한 @Published 프로퍼티를 통해 SwiftUIView에서 일어난 이벤트를 전달받아 처리한다.
- 마찬가지로 ViewController에서 일어난 이벤트도 ViewModel의 @Published 프로퍼티를 통해 SwiftUIView로 전달하여 뷰업데이트를 처리한다.
