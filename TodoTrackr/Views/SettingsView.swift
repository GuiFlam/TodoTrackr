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
    var notes: FetchedResults<Note>
    
    @Binding var createNewCategory: Bool
    
    @EnvironmentObject var dataController: DataManager
    
    @Environment(\.managedObjectContext) private var moc
    
    @State private var presentShareSheet: Bool = false
    @State private var presentFilePicker: Bool = false
    @State var isImportingTodos = false
    @State var isImportingNotes = false
    @State private var shareURL: URL = URL(string: "https://apple.com")!
    
    @State var isSubmittingPasswordDecryptionCategories = false
    @State var isSubmittingPasswordDecryptionNotes = false
    @State var isSubmittingPasswordEncryptionCategories = false
    @State var isSubmittingPasswordEncryptionNotes = false
    @State private var passwordInput = ""
    @State var successUrl: URL = URL(string: "https://apple.com")!
    @State var showAlert = false
    @State var showSheet = false
    
    
    var body: some View {
        ZStack {
            List {
                Section("Export / Import", content: {
                    Button(action: {
                        self.showSheet = true
                        isSubmittingPasswordEncryptionCategories = true
                       
                        //exportCoreData()
                    }, label: {
                        Text("Export Todos")
                            .font(.custom(MyFont.font, size: 16))
                    })
                    .listRowBackground(Color("TodoColor2").opacity(0.8))
                    Button(action: {
                        isImportingTodos = true
                        isImportingNotes = false
                        presentFilePicker.toggle()
                        
                    }, label: {
                        Text("Import Todos")
                            .font(.custom(MyFont.font, size: 16))
                    })
                    .listRowBackground(Color("TodoColor2").opacity(0.8))
                    Button(action: {
                        isSubmittingPasswordEncryptionNotes = true
                        self.showSheet = true
                        //exportCoreData()
                    }, label: {
                        Text("Export Notes")
                            .font(.custom(MyFont.font, size: 16))
                    })
                    .listRowBackground(Color("TodoColor2").opacity(0.8))
                    Button(action: {
                        isImportingNotes = true
                        isImportingTodos = false
                        presentFilePicker.toggle()
                        
                    }, label: {
                        Text("Import Notes")
                            .font(.custom(MyFont.font, size: 16))
                    })
                    .listRowBackground(Color("TodoColor2").opacity(0.8))
                })
                .listRowSeparatorTint(.white)
                .foregroundColor(.white)
                
            }
            .background(Color("BackgroundColor"))
            .scrollContentBackground(.hidden)
        }
        .sheet(isPresented: $isSubmittingPasswordEncryptionCategories, content: {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack {
                    Text("Enter the password that will be used for encryption")
                        .font(.custom(MyFont.font, size: 18))
                    Text("If you lose this password the file will be encrypted forever!")
                        .font(.custom(MyFont.font, size: 11)).bold()
                        .padding()
                    TextField("Enter Password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Export") {
                        exportCoreData(password: passwordInput, entityName: "Categorie")
                    }
                    .font(.custom(MyFont.font, size: 24))
                    .fontWeight(.semibold)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color("TodoColor2"))
                    .cornerRadius(20)
                }
                .padding()
            }
            .presentationDetents([.height(300)])
            
        })
        .sheet(isPresented: $isSubmittingPasswordEncryptionNotes, content: {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack {
                    Text("Enter the password that will be used for encryption")
                        .font(.custom(MyFont.font, size: 18))
                    Text("If you lose this password the file will be encrypted forever!")
                        .font(.custom(MyFont.font, size: 11)).bold()
                        .padding()
                    TextField("Enter Password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Export") {
                        exportCoreData(password: passwordInput, entityName: "Note")
                    }
                    .font(.custom(MyFont.font, size: 24))
                    .fontWeight(.semibold)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color("TodoColor2"))
                    .cornerRadius(20)
                }
                .padding()
            }
            .presentationDetents([.height(300)])
        })
        .sheet(isPresented: $isSubmittingPasswordDecryptionCategories, content: {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack {
                    Text("Enter the password that was used for encryption")
                        .font(.custom(MyFont.font, size: 18))
                    TextField("Enter Password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Import") {
                        importJSON(successUrl, password: passwordInput, entityName: "Categorie")
                    }
                    .font(.custom(MyFont.font, size: 24))
                    .fontWeight(.semibold)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color("TodoColor2"))
                    .cornerRadius(20)
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
            .presentationDetents([.height(300)])
        })
        .sheet(isPresented: $isSubmittingPasswordDecryptionNotes, content: {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack {
                    Text("Enter the password that was used for encryption")
                        .font(.custom(MyFont.font, size: 18))
                    TextField("Enter Password", text: $passwordInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Import") {
                        importJSON(successUrl, password: passwordInput, entityName: "Note")
                    }
                    .font(.custom(MyFont.font, size: 24))
                    .fontWeight(.semibold)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Color("TodoColor2"))
                    .cornerRadius(20)
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
                    if isImportingTodos {
                        isSubmittingPasswordDecryptionCategories = true
                    }
                    else {
                        isSubmittingPasswordDecryptionNotes = true
                    }
                    
                    self.successUrl = success
                    self.showSheet = true
                    //importJSON(success)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    func importJSON(_ url: URL, password: String, entityName: String) {
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
                        
                        if entityName == "Categorie" {
                            let decoder = JSONDecoder()
                            decoder.userInfo[.context!] = moc
                            for i in categories.indices {
                                dataController.deleteCategory(categories[i])
                            }
                            try moc.save()
                            let decodedJson = try decoder.decode([Categorie].self, from: string.data(using: .utf8)!)
                            try moc.save()
                        }
                        else {
                            print("here")
                            let decoder = JSONDecoder()
                            decoder.userInfo[.context!] = moc
                            for i in notes.indices {
                                dataController.deleteNote(notes[i])
                            }
                            print("here middle")
                            print(parts[1])
                            print(string)
                            try moc.save()
                            let decodedJson = try decoder.decode([Note].self, from: string.data(using: .utf8)!)
                            print("here after")
                            try moc.save()
                        }
                        
                        
                        withAnimation {
                            isSubmittingPasswordDecryptionNotes = false
                            isSubmittingPasswordDecryptionCategories = false
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
    
    func exportCoreData(password: String, entityName: String) {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            
            if entityName == "Categorie" {
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
                            let pathURL = tempUrl.appending(component: "TodoTrackr: Todos.txt")
                            
                            let encodedString = base64combined! + ":" + key.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
                            
                            try encodedString.write(to: pathURL, atomically: true, encoding: .utf8)
                            // Saved successfully
                            shareURL = pathURL
                            presentShareSheet.toggle()
                            
                            withAnimation {
                                isSubmittingPasswordEncryptionCategories = false
                                isSubmittingPasswordEncryptionNotes = false
                                passwordInput = ""
                            }
                        }
                    }
                } else {
                    print("Data is different")
                }
            }
            else {
                let items = try moc.fetch(request).compactMap {
                    $0 as? Note
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
                            let pathURL = tempUrl.appending(component: "TodoTrackr:Notes.txt")
                            
                            let encodedString = base64combined! + ":" + key.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
                            
                            try encodedString.write(to: pathURL, atomically: true, encoding: .utf8)
                            // Saved successfully
                            shareURL = pathURL
                            presentShareSheet.toggle()
                            
                            withAnimation {
                                isSubmittingPasswordEncryptionCategories = false
                                isSubmittingPasswordEncryptionNotes = false
                                passwordInput = ""
                            }
                        }
                    }
                } else {
                    print("Data is different")
                }
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
