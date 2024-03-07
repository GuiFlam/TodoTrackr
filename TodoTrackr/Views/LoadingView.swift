//
//  LoadingView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-03-05.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .cornerRadius(40)
                Text("TodoTrackr")
                    .font(.custom(MyFont.font, size: 52))
            }
        }
    }
}

#Preview {
    LoadingView()
}
