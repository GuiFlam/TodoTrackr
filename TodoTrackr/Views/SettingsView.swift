//
//  SettingsView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-02-27.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    
    var categories: FetchedResults<Categorie>
    
    @Binding var createNewCategory: Bool
    
    @EnvironmentObject var dataController: DataManager
    
    @Environment(\.managedObjectContext) private var moc
    
    @State private var presentShareSheet: Bool = false
    @State private var presentFilePicker: Bool = false
    @State private var shareURL: URL = URL(string: "https://apple.com")!
    
    var body: some View {
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
                    exportCoreData()
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
        .fileImporter(isPresented: $presentFilePicker, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let success):
                if success.startAccessingSecurityScopedResource() {
                    importJSON(success)
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    func importJSON(_ url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo[.context!] = moc
            for i in categories.indices {
                dataController.deleteCategory(categories[i])
            }
            try moc.save()
            let items = try decoder.decode([Categorie].self, from: jsonData)
            try moc.save()
            
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
    func exportCoreData() {
        do {
            if let name = Categorie.entity().name {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let items = try moc.fetch(request).compactMap {
                    $0 as? Categorie
                }
                print(items)
                let todos = items[0].todos?.allObjects as! [Todo]
                print(todos[0])
                
                let jsonData = try JSONEncoder().encode(items)
                
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
