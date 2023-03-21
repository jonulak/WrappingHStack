//
//  File.swift
//  
//
//  Created by Jon Onulak on 3/20/23.
//

import SwiftUI

extension View {
    var size: CGSize {
        UIHostingController(rootView: self).view.intrinsicContentSize
    }
}
