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
                            Text(category.title ?? "")
                                .font(.custom(MyFont.font, size: 24)).bold()
                                .padding(.horizontal, 13)
                                .padding(.top, 20)
                            
                            // This filters the todos for the search results
                            // if the searchText is empty, the todos are sorted according to their date
                            var searchResults: [Todo] {
                                    if searchText.isEmpty {
                                        return (category.todos?.allObjects as! [Todo]).sorted { (item1, item2) -> Bool in
                                            let timeDifference1 = (item1.date ?? Date()).timeIntervalSinceNow
                                            let timeDifference2 = (item2.date ?? Date()).timeIntervalSinceNow
                                            return abs(timeDifference1) < abs(timeDifference2)
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
                        
                .frame(maxHeight: .infinity)
                .sheet(isPresented: $createNewTodo, content: {
                    NewTask(categories: categories)
                        .presentationDetents([.height(600)])
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
            }
            NavigationStack {
                
                SettingsView(categories: categories, createNewCategory: $createNewCategory)
                
                
            }
            .background(Color("BackgroundColor"))
            .tabItem {
                Image(systemName: "gear")
            }
            
        }
        .tint(.white)
    }
}

#Preview {
    MainView()
}

