//
//  MapOverContentView.swift
//  MapSUSample
//

import SwiftUI
import MapKit

struct MapOverView: View {
    @EnvironmentObject var vm: MapOverViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                Text("위치: \(vm.region.center.latitude), \(vm.region.center.longitude)")
                    .frame(height: 20)
                List {
                    ForEach(vm.searchResults, id: \.self) { item in
                        let name = item.name ?? "cafe"
                        let location = item.placemark.coordinate
                        HStack {
                            Text(name)
                            Spacer()
                            Text("위치: \(location.latitude, specifier: "%.3f"), \(location.longitude, specifier: "%.3f")")
                        }
                        .id(item)
                        .onTapGesture {
                            vm.selectItem = item
                        }
                    }
                }
                .onReceive(vm.$selectPin) { annotation in
                    guard let annotation,
                          let item = vm.searchResults.first(where: { $0.placemark.coordinate == annotation.coordinate }) else {
                        return
                    }
                    
                    withAnimation {
                        proxy.scrollTo(item, anchor: .top)
                    }
                }
            }
            .padding(.top, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray)
            .cornerRadius(16)
            .shadow(radius: 4)
            .edgesIgnoringSafeArea([.bottom])
        }
    }
}
