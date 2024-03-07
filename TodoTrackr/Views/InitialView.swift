//
//  InitialView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-03-05.
//

import SwiftUI
import LocalAuthentication

struct InitialView: View {
    @State var isLoading: Bool = true
    @State var isUnlocked: Bool = false
    
    var body: some View {
        ZStack {
            if !isUnlocked {
                ZStack {
                    Color("BackgroundColor")
                        .ignoresSafeArea()
                }
            }
            else {
                if isLoading {
                    
                    LoadingView()
                    
                }
                else {
                    MainView()
                }
            }
            
        }
        .onAppear {
            authenticate()
            
        }
        
       
        
    }
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.isUnlocked = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isLoading = false
                            }
                            
                        }
                    }
                   
                    
                } else {
                    // error
                }
            }
        } else {
            // no biometrics
        }
    }
}

#Preview {
    InitialView()
}
