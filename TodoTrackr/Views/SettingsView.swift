//
//  SettingsView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//

import SwiftUI
import CoreData
import CryptoKit

struct SettingsView: View {
    
    var categories: FetchedResults<Categorie>
    
    @Binding var createNewCategory: Bool
    
    @EnvironmentObject var dataController: DataManager
    
    @Environment(\.managedObjectContext) private var moc
    
    @State private var presentShareSheet: Bool = false
    @State private var presentFilePicker: Bool = false
    @State private var shareURL: URL = URL(string: "https://apple.com")!
    
    @State var isSubmittingPassword = false
    @State var isSubmittingPasswordEncryption = false
    @State private var passwordInput = ""
    @State var successUrl: URL = URL(string: "https://apple.com")!
    @State var showAlert = false
    
    
    var body: some View {
        ZStack {
            if isSubmittingPassword {
                VStack {
                        TextField("Enter Password", text: $passwordInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Submit") {
                            do {
                                importJSON(successUrl, password: passwordInput)
                            } catch {
                               
                                print("error")
                            }
                        }
                        .padding()
                    }
                .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Wrong Password"),
                                message: Text("You have entered the wrong decryption password..."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    .padding()
                    .zIndex(10)
            }
            if isSubmittingPasswordEncryption {
                VStack {
                        TextField("Enter Password", text: $passwordInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Submit") {
                            exportCoreData(password: passwordInput)
                        }
                        .padding()
                    }
                    .padding()
                    .zIndex(10)
            }
            List {
                Section("Categories", content: {
                    ForEach(categories, id: \.self) { category in
                        Text(category.title ?? "")
                            .listRowBackground(Color("TodoColor2").opacity(0.8))
                            .font(.custom(MyFont.font, size: 16))
                    }
                    .onDelete(perform: deleteCategorie)
                    
                    Button(action: {
                        createNewCategory.toggle()
                    }, label: {
                        Text("Add Category")
                            .font(.custom(MyFont.font, size: 16)).bold()
                    })
                    
                })
                Section("Import / Export", content: {
                    Button(action: {
                        isSubmittingPasswordEncryption = true
                        //exportCoreData()
                    }, label: {
                        Text("Export as JSON")
                            .font(.custom(MyFont.font, size: 16))
                    })
                    Button(action: {
                        presentFilePicker.toggle()
                    }, label: {
                        Text("Import JSON")
                            .font(.custom(MyFont.font, size: 16))
                    })
                })
                
            }
            .background(Color("BackgroundColor"))
            .scrollContentBackground(.hidden)
        }
       
        
        .sheet(isPresented: $createNewCategory, content: {
            NewCategorie()
                .presentationDetents([.height(300)])
        })
        .navigationTitle("Settings")
        .sheet(isPresented: $presentShareSheet) {
            deleteTempFile()
        } content: {
            CustomShareSheet(url: $shareURL)
        }
        .fileImporter(isPresented: $presentFilePicker, allowedContentTypes: [.text]) { result in
            switch result {
            case .success(let success):
                if success.startAccessingSecurityScopedResource() {
                    // pop up keyboard and ask user to type in the password, if the password is right, run the function.
                    isSubmittingPassword = true
                    self.successUrl = success
                    //importJSON(success)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    func importJSON(_ url: URL, password: String) {
        do {
            let fileData = try Data(contentsOf: url)
            if let fileContent = String(data: fileData, encoding: .utf8) {
                let parts = fileContent.split(separator: ":")
                let base64Combined = Data(base64Encoded: String(parts[0]))
                let sealedBox = try AES.GCM.SealedBox(combined: base64Combined!)
                
                //print(parts[1])
                
                guard let keyData = Data(base64Encoded: String(parts[1])) else {
                    print("Failed to decode key data from base64 string.")
                    return
                }
                let symmetricKey = SymmetricKey(data: keyData)
                
                let extractedKey = CryptoKit.HKDF<SHA256>.extract(inputKeyMaterial: symmetricKey, salt: password.data(using: .utf8))
                
                let key = CryptoKit.HKDF<SHA256>.expand(pseudoRandomKey: extractedKey, info: Data(), outputByteCount: 32)
                
                do {
                    let decryptedData = try AES.GCM.open(sealedBox, using: key)
                    
                    if let string = String(data: decryptedData, encoding: .utf8) {
                        
                        let decoder = JSONDecoder()
                        decoder.userInfo[.context!] = moc
                        for i in categories.indices {
                            dataController.deleteCategory(categories[i])
                        }
                        try moc.save()
                        let decodedJson = try decoder.decode([Categorie].self, from: string.data(using: .utf8)!)
                        try moc.save()
                        
                        withAnimation {
                            isSubmittingPassword = false
                            passwordInput = ""
                        }
                        
                        
                    }
                }
                catch {
                    print("WRONG PASSWORD")
                    showAlert.toggle()
                }
                
                
                
            } else {
                print("Unable to convert data to string.")
            }
            
        } catch {
            
        }
    }
    func deleteTempFile() {
        do {
            try FileManager.default.removeItem(at: shareURL)
        } catch {
            
        }
    }
    private func deleteCategorie(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            dataController.deleteCategory(category)
            try? moc.save()
        }
    }
    func exportCoreData(password: String) {
        do {
            if let name = Categorie.entity().name {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let items = try moc.fetch(request).compactMap {
                    $0 as? Categorie
                }
                //print(items)
                //let todos = items[0].todos?.allObjects as! [Todo]
                //print(todos[0])
                
                let jsonData = try JSONEncoder().encode(items)
                
                
                let key = SymmetricKey(size: .bits256)
                
                let newKey = CryptoKit.HKDF<SHA256>.deriveKey(inputKeyMaterial: key, salt: password.data(using: .utf8)!, outputByteCount: 32)
                
                let sealedBox = try! AES.GCM.seal(jsonData, using: newKey)
                
                //print(sealedBox.ciphertext)
                
                //let base64String = sealedBox.ciphertext.base64EncodedString()
                //print(base64String)
                
                let base64combined = sealedBox.combined?.base64EncodedString()
                
                let newSealedBox = try! AES.GCM.SealedBox(combined: Data(base64Encoded: base64combined!)!)
                
                let decryptedData = try! AES.GCM.open(newSealedBox, using: newKey)
                
                
                if decryptedData == jsonData {
                    print("Data is the same")
                    if let string = String(data: decryptedData, encoding: .utf8) {
                        print(string)
                        
                        if let tempUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let pathURL = tempUrl.appending(component: "TodoTrackr: \(Date().formatted(date: .complete, time: .omitted)).txt")
                            
                            let encodedString = base64combined! + ":" + key.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
                            
                            try encodedString.write(to: pathURL, atomically: true, encoding: .utf8)
                            // Saved successfully
                            shareURL = pathURL
                            presentShareSheet.toggle()
                            
                            withAnimation {
                                isSubmittingPasswordEncryption = false
                                passwordInput = ""
                            }
                        }
                    }
                } else {
                    print("Data is different")
                }
                
                
                
                
                
                /*
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                    
                    if let tempUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let pathURL = tempUrl.appending(component: "TodoTrackr: \(Date().formatted(date: .complete, time: .omitted)).json")
                        try jsonString.write(to: pathURL, atomically: true, encoding: .utf8)
                        // Saved successfully
                        shareURL = pathURL
                        presentShareSheet.toggle()
                    }
                     
                }
                 */
                 
            }
        } catch {
            print(error)
        }
    }
    
}

struct CustomShareSheet: UIViewControllerRepresentable {
    @Binding var url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
