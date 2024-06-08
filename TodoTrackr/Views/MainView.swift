//
//  ContentView.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-21.
//

import SwiftUI

struct MainView: View {
    
    @State private var createNewTodo: Bool = false
    @State private var editTodo: Bool = false
    @State private var indexCategoryToEdit: Int = 0
    @State private var indexTodoToEdit: Int = 0
    @State private var createNewCategory: Bool = false
    @State private var searchText: String = ""
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(entity: Categorie.entity(), sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]) private var categories: FetchedResults<Categorie>
    
    @FetchRequest(entity: Note.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]) private var notes: FetchedResults<Note>
    
    @EnvironmentObject private var dataController: DataManager
    
    
    init() {
        let appear = UINavigationBarAppearance()

        let atters: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: MyFont.font, size: 40)!
        ]

        appear.largeTitleTextAttributes = atters
        UINavigationBar.appearance().standardAppearance = appear
     }
    
    var body: some View {
        TabView {
            NavigationStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        
                        ForEach(categories, id:\.self) { category in
                            HStack {
                                Text(category.title ?? "")
                                    .font(.custom(MyFont.font, size: 24)).bold()
                                    .padding(.horizontal, 13)
                                    .padding(.top, 20)
                                    
                            }
                            .contextMenu {
                                Button(action: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                                        withAnimation {
                                            dataController.deleteCategory(category)
                                        }
                                    }
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }
                            
                            
                            // This filters the todos for the search results
                            // if the searchText is empty, the todos are sorted according to their date
                            
                            var searchResults: [Todo] {
                                    if searchText.isEmpty {
                                        return (category.todos?.allObjects as! [Todo]).sorted { (item1, item2) -> Bool in
                                            return item1.date! < item2.date!
                                        }
                                    } else {
                                        return (category.todos?.allObjects as! [Todo]).filter { ($0.title ?? "").contains(searchText) }
                                    }
                                }
                            ForEach(searchResults, id:\.self) { todo in
                                
                                TodoView(todo: todo, category: category, indexTodoToEdit: $indexTodoToEdit, indexCategoryToEdit: $indexCategoryToEdit, editTodo: $editTodo, categories: categories)
                                    
                                }
                            Divider()
                                .overlay(Color.white.opacity(0.8))
                                .padding(.horizontal)
                                .padding(.vertical, 7)
                            }
                        
                            
                        }
                    }
                    .background(Color("BackgroundColor"))
                    .navigationTitle("TodoTrackr")
                    .toolbar {
                        
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Button(action: {
                                createNewTodo.toggle()
                            }, label: {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .padding(7)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .foregroundColor(.black)
                            })
                        })
                    }
                }
            .onAppear {
                /*
                let note = Note(context: moc)
                note.text = "This is another note"
                try? moc.save()
                 */
                 
            }
                .frame(maxHeight: .infinity)
                .sheet(isPresented: $createNewTodo, content: {
                    NewTask(categories: categories)
                        .presentationDetents([.height(800)])
                })
                .sheet(isPresented: $editTodo, content: {
                    EditTodo(categories: categories, indexTodoToEdit: $indexTodoToEdit, indexCategoryToEdit: $indexCategoryToEdit)
                        .presentationDetents([.height(400)])
                        .onAppear {
                            print(indexCategoryToEdit)
                            
                        }
                })
            .searchable(text: $searchText)
            .font(.custom(MyFont.font, size: 18))
            .tabItem {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
                Text("Todos")
            }
            
            NavigationStack {
                CalendarView(categories: categories)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }
            
            NavigationStack {
                
                
                List {
                    ForEach(notes, id:\.self) { note in
                        NavigationLink(destination: {
                            EditNoteView(note: note)
                        }, label: {
                            Text(firstLine(of: note.text ?? ""))
                            
                                .font(.custom(MyFont.font, size: 16))
                        })
                        .listRowBackground(Color("TodoColor2").opacity(0.8))
                        .listRowSeparatorTint(.white)
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    .onDelete(perform: deleteNote)
                }
                .navigationTitle("Notes")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    
                    ToolbarItem(placement: .topBarTrailing, content: {
                        NavigationLink(destination: {
                            NewNoteView()
                        }, label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .padding(7)
                                .background(.white)
                                .clipShape(Circle())
                                .foregroundColor(.black)
                        })
                    })
                }
              
                
                .scrollContentBackground(.hidden)
                .background(Color("BackgroundColor"))
       
            }
            .tabItem {
                Image(systemName: "list.clipboard")
                Text("Notes")
            }
            
            
            /*
            NavigationStack {
                PortfolioView()
            }
            .tabItem {
                Image(systemName: "chart.xyaxis.line")
                Text("Portfolio")
            }
            */
            
            NavigationStack {
                
                SettingsView(categories: categories, notes: notes, createNewCategory: $createNewCategory)
                
                
            }
            .background(Color("BackgroundColor"))
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            
        }
        .tint(.white)
        
    }
    private func firstLine(of string: String) -> String {
            return string.split(separator: "\n").first.map(String.init) ?? ""
        }
    
    private func deleteNote(at offsets: IndexSet) {
            for index in offsets {
                let note = notes[index]
                dataController.deleteNote(note)
            }
            do {
                try moc.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    private struct CustomButtonStyle: ButtonStyle {
        let isEnabled: Bool
        
        @ViewBuilder
        func makeBody(configuration: Configuration) -> some View {
            let backgroundColor = isEnabled ? Color.purple : Color(UIColor.lightGray)
            let pressedColor = Color.red
            let background = configuration.isPressed ? pressedColor : backgroundColor
            
            configuration.label
                .foregroundColor(.white)
                .background(background)
                .cornerRadius(8)
        }
    }
}

#Preview {
    MainView()
}

