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
    
    var body: some View {
        TabView {
            NavigationStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        
                        ForEach(categories, id:\.self) { category in
                            Text(category.title ?? "")
                                .font(.system(size: 24, weight: .semibold))
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
                            }
                            Divider()
                        }
                    }
                    .navigationTitle("Todos")
                    .toolbar {
                        
                        ToolbarItem(placement: .principal, content: {
                            Text("\((Date()).format("MMM dd, yyyy"))")
                        })
                        
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
                })
                
            
            .searchable(text: $searchText)
            .tabItem {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            NavigationStack {
                
                List {
                    ForEach(categories, id: \.self) { category in
                        Text(category.title ?? "")
                    }
                    .onDelete(perform: deleteCategorie)
                    
                    Button(action: {
                        createNewCategory.toggle()
                    }, label: {
                        Text("Add Category")
                            .foregroundStyle(.blue)
                    })
                }
               
                .sheet(isPresented: $createNewCategory, content: {
                    NewCategorie()
                        .presentationDetents([.height(300)])
                })
                .navigationTitle("Settings")
                
            }
            .tabItem {
                Image(systemName: "gear")
            }
            
        }
        .tint(.white)
       
    }
    private func deleteCategorie(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            dataController.deleteCategory(category)
            try? moc.save()
        }
    }
}

#Preview {
    MainView()
}
