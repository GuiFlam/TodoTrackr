//
//  PortfolioVIew.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-04-01.
//

import SwiftUI
import Foundation


struct Roi: Codable {
    let times: Double?
    let currency: String?
    let percentage: Double?
}
struct Coin: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let current_price: Double
    let market_cap: Double?
    let market_cap_rank: Int?
    let fully_diluted_valuation: Double?
    let total_volume: Double?
    let high_24h: Double?
    let low_24h: Double?
    let price_change_24h: Double?
    let price_change_percentage_24h: Double?
    let market_cap_change_24h: Double?
    let market_cap_change_percentage_24h: Double?
    let circulating_supply: Double?
    let total_supply: Double?
    let max_supply: Double?
    let ath: Double?
    let ath_change_percentage: Double?
    let ath_date: String?
    let atl: Double?
    let atl_change_percentage: Double?
    let atl_date: String?
    let roi: Roi?
    let last_updated: String?
}

struct TetherData: Codable {
    let tether: TetherInfo
}

struct TetherInfo: Codable {
    let cad: Double
}

struct CoinIdentification: Codable, Hashable {
    let id: String
    let symbol: String
    let name: String
}

struct PortfolioCoin: Decodable, Encodable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    var current_price: Double
    var amount: Double = 0.0
}

struct PortfolioView: View {
    @AppStorage("coinIds") var coinIds: Data?
    @AppStorage("portfolio") var portfolio: Data?
    @State var portfolioCoins: [PortfolioCoin] = []
    @State var searchText: String = ""
    @State var usdPrice: Bool = true
    @State var currentBalance: Double = 0.0
    @State var balanceIsFetched: Bool = false
    
    var body: some View {
        var searchResults: [CoinIdentification] {
            if searchText.isEmpty {
                return []
            } else {
                let coinIds = try? JSONDecoder().decode([CoinIdentification].self, from: coinIds!)
                return coinIds!.filter { $0.symbol.lowercased().hasPrefix(searchText.lowercased()) }
            }
        }
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            VStack {
                ForEach(searchResults.prefix(15), id: \.self) { coin in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(coin.symbol)
                                .font(.headline)
                            Text(coin.name)
                                .font(.callout)
                        }
                        Spacer()
                        Button("Add") {
                            let headers = ["x-cg-demo-api-key": "CG-LWL9frrfAxZknaL5LcQgFwfi"]
                            
                            let request = NSMutableURLRequest(url: NSURL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=" + coin.id)! as URL,
                                                              cachePolicy: .useProtocolCachePolicy,
                                                              timeoutInterval: 10.0)
                            request.httpMethod = "GET"
                            request.allHTTPHeaderFields = headers
                            
                            let session = URLSession.shared
                            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                                if (error != nil) {
                                    print(error as Any)
                                } else {
                                    let httpResponse = response as? HTTPURLResponse
                                    print(httpResponse)
                                    
                                    let fetchedCoin = try? JSONDecoder().decode([Coin].self, from: data!)
                                    var coinToAppend = PortfolioCoin(id: coin.id, symbol: coin.symbol, name: coin.name, image: fetchedCoin![0].image, current_price: fetchedCoin![0].current_price)
                                    self.portfolioCoins.append(coinToAppend)
                                    portfolio = try! JSONEncoder().encode(portfolioCoins)
                                }
                            })
                            dataTask.resume()
                            
                            
                            
                        }
                        .foregroundColor(.blue)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                HStack {
                    Button(action: {
                        usdPrice.toggle()
                        if !usdPrice {
                            let headers = ["x-cg-demo-api-key": "CG-LWL9frrfAxZknaL5LcQgFwfi"]

                            let request = NSMutableURLRequest(url: NSURL(string: "https://api.coingecko.com/api/v3/simple/price?ids=tether&vs_currencies=cad")! as URL,
                                                                    cachePolicy: .useProtocolCachePolicy,
                                                                timeoutInterval: 10.0)
                            request.httpMethod = "GET"
                            request.allHTTPHeaderFields = headers

                            let session = URLSession.shared
                            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                              if (error != nil) {
                                print(error as Any)
                              } else {
                                let httpResponse = response as? HTTPURLResponse
                                print(httpResponse)
                                  let fetchedPrice = String(data: data!, encoding: .utf8)
                                  do {
                                      // Parse JSON data using JSONDecoder
                                      let tetherData = try JSONDecoder().decode(TetherData.self, from: data!)
                                      
                                      // Access the CAD value
                                      let cadValue = tetherData.tether.cad
                                      print("CAD value: \(cadValue)")
                                      currentBalance = portfolioCoins.reduce(0) { $0 + $1.current_price * $1.amount * cadValue }
                                  } catch {
                                      print("Error parsing JSON: \(error)")
                                  }
                              }
                            })

                            dataTask.resume()
                        }
                        else {
                            currentBalance = portfolioCoins.reduce(0) { $0 + $1.current_price * $1.amount }
                        }
                    }, label: {
                        Text(usdPrice ? "USD" : "CAD")
                    })
                    
                    Text("$" + String(format: "%.2f", currentBalance))
                        .font(.largeTitle).bold()
                }
               
                
                ScrollView {
                    ForEach(portfolioCoins.sorted(by: { $0.current_price * $0.amount > $1.current_price * $1.amount }), id: \.id) { coin in
                        NavigationLink(destination: {
                            CoinTransactionView(coin: coin, portfolioCoins: $portfolioCoins)
                        }, label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        VStack {
                                            AsyncImage(url: URL(string: coin.image!)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                case .failure(let error):
                                                    Text("Failed to load image: \(error.localizedDescription)")
                                                case .empty:
                                                    ProgressView()
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 30, height: 30) // Adjust size as needed
                                            Text(coin.symbol.uppercased())
                                                .font(.headline)
                                        }
                                        .frame(width: 70, height: 70)
                                        .padding(.trailing, 10)
                                    }
                                    
                                    Text("$" + String(format: "%.6f", coin.current_price)).bold()
                                    
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("$" + String(format: "%.2f", coin.current_price * coin.amount))
                                            .font(.callout).bold()
                                        Text(String(coin.amount) + " " + coin.symbol.uppercased())
                                            .font(.caption)
                                        
                                    }
                                    .onAppear {
                                        print()
                                    }
                                    
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .contextMenu {
                                Button(action: {
                                    let index = portfolioCoins.firstIndex(where: { $0.id == coin.id })
                                    portfolioCoins.remove(at: index!)
                                    portfolio = try! JSONEncoder().encode(portfolioCoins)
                                }, label: {
                                    Text("Delete")
                                })
                            }
                        })
                        
                    }
                }
                
            }
            .navigationTitle("Portfolio")
            
            .searchable(text: $searchText)
            .onAppear {
                if portfolio != nil {
                    self.portfolioCoins = try! JSONDecoder().decode([PortfolioCoin].self, from: portfolio!)
                }
                fetchData()
                
                
            }
        }
        
    }
    func fetchData() {
        if coinIds == nil {
            let headers = ["x-cg-demo-api-key": "CG-LWL9frrfAxZknaL5LcQgFwfi"]
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://api.coingecko.com/api/v3/coins/list")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse)
                    let coins = try? JSONDecoder().decode([CoinIdentification].self, from: data!)
                    for i in coins!.indices {
                        print(String(i+1) + " - " + coins![i].name)
                    }
                    coinIds = try? JSONEncoder().encode(coins)
                }
            })
            
            dataTask.resume()
        }
        else {
            let headers = ["x-cg-demo-api-key": "CG-LWL9frrfAxZknaL5LcQgFwfi"]
            
            var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids="
            
            
            if portfolioCoins.isEmpty {
                return
            }
            
            for i in portfolioCoins.indices {
                if i == portfolioCoins.count - 1 {
                    url += portfolioCoins[i].id
                } else {
                    url += portfolioCoins[i].id + "%2C"
                }
            }
            
            let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            print(url)
            
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error as Any)
                } else {
                    let fetchedCoins = try? JSONDecoder().decode([Coin].self, from: data!)
                    for i in fetchedCoins!.indices {
                        print(fetchedCoins![i].name + " - " + String(fetchedCoins![i].current_price))
                    }
                    for i in portfolioCoins.indices {
                        for j in fetchedCoins!.indices {
                            if portfolioCoins[i].id == fetchedCoins![j].id {
                                portfolioCoins[i].current_price = fetchedCoins![j].current_price
                                if !balanceIsFetched {
                                    currentBalance += portfolioCoins[i].current_price * portfolioCoins[i].amount
                                }
                               
                            }
                        }
                    }
                    balanceIsFetched = true
                    portfolio = try! JSONEncoder().encode(portfolioCoins)
                }
            })
            
            dataTask.resume()
        }
        
        
        
    }
}
