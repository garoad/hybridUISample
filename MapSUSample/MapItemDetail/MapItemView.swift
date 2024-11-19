//
//  MapItemView.swift
//  MapSUSample
//

import Foundation
import SwiftUI
import MapKit

struct MapItemView: View {
    @EnvironmentObject var vm: MapItemViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                Button {
                    vm.viewEvent = .pop
                } label: {
                    Image(systemName: "arrowshape.backward.fill")
                        .resizable()
                        .foregroundColor(.orange)
                        .frame(width: 32, height: 32)
                }
                Spacer()
            }
            .padding(.top, 10)
            .frame(height: 44)
            
            Text(vm.item.name ?? "Unknown")
                .font(.largeTitle)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            if let placemark = vm.item.placemark.formattedAddress {
                Text(placemark)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Text("주소없음")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            ZStack {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: vm.item.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))
                .frame(height: 250)
                .cornerRadius(12)
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    .offset(x: 0, y: -15)
            }
            .frame(height: 250)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
}

extension MKPlacemark {
    var formattedAddress: String? {
        let addressLines = [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
        return addressLines.compactMap { $0 }.joined(separator: ", ")
    }
}
