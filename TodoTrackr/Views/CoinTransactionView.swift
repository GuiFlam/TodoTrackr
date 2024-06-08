//
//  CoinTransactionView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-04-02.
//

import SwiftUI

struct CoinTransactionView: View {
    var coin: PortfolioCoin
    
    @AppStorage("portfolio") var portfolio: Data?
    @Binding var portfolioCoins: [PortfolioCoin]
    
    @State var selection: Int = 0
    
    @State var amount: Double = 0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Picker("Transaction Type", selection: $selection) {
                        Text("Buy").tag(0)
                        Text("Sell").tag(1)
                    }
                    .pickerStyle(.segmented)
                    TextField(coin.symbol.uppercased() + " amount: ", value: $amount, formatter: formatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        for i in 0..<portfolioCoins.count {
                            if portfolioCoins[i].id == coin.id {
                                if selection == 0 {
                                    portfolioCoins[i].amount += amount
                                    print("Bought \(amount) \(coin.symbol)")
                                    
                                } else {
                                    // Sell
                                    portfolioCoins[i].amount -= amount
                                    print("Sold \(amount) \(coin.symbol)")
                                }
                            }
                        }
                        portfolio = try! JSONEncoder().encode(portfolioCoins)
                        print(portfolioCoins.count)
                        
                    }, label: {
                        Text(selection == 0 ? "Buy" : "Sell")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    })
                }
            }
            
            .navigationTitle(coin.symbol.uppercased())
        }
    }
}
