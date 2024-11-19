//
//  MapHostingViewController.swift
//  MapSUSample
//

import SwiftUI

/**
 iOS 15 에서만 내비게이션바 숨김이 정상동작하지 않는 이슈 해결하기 위해 HostingViewController override
*/

final class MapHostingViewController<Content>: UIHostingController<AnyView> where Content: View {
    init(rootView: Content) {
        super.init(rootView: AnyView(rootView.navigationBarHidden(true)))
    }

    @available(*, unavailable)
    @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var navigationController: UINavigationController? {
        nil
    }
}
