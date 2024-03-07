//
//  InitialView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-03-05.
//

import SwiftUI

struct InitialView: View {
    @State var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            if isLoading {
                
                LoadingView()
                
            }
            else {
                MainView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
                withAnimation {
                    isLoading = false
                }
                
            }
        }
        
    }
}

#Preview {
    InitialView()
}
