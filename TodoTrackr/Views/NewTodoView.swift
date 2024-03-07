//
//  NewTask.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-22.
//

import SwiftUI


struct NewTask: View {
    @Environment(\.dismiss) private var dismiss
    @State private var todoTitle: String = ""
    @State private var todoCaption: String = ""
    @State private var todoDate: Date = .init()
    @State private var todoColor: String = "#111111"
    @State private var selectedCategory: String = "LOG100"
    @State var selection: String = "Todo"
    
    @Environment(\.managedObjectContext) var moc
    
    var categories: FetchedResults<Categorie>
    
    @EnvironmentObject var dataController: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .tint(.red)
            })
            .hSpacing(.leading)
            
            Picker("Selection", selection: $selection, content: {
                Text("Todo")
                    .tag("Todo")
                Text("Category")
                    .tag("Category")
            })
            .pickerStyle(.segmented)
            
            if selection == "Todo" {
                
                VStack(alignment: .leading, spacing: 8, content: {
                    
                    
                    Text("Todo Title")
                        .font(.custom(MyFont.font, size: 12))
                        .foregroundStyle(.gray)
                    
                    TextField("Title", text: $todoTitle)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                    
                    Text("Todo Caption")
                        .font(.custom(MyFont.font, size: 12))
                        .foregroundStyle(.gray)
                    
                    TextField("Caption", text: $todoCaption, axis: .vertical)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                    
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category.title ?? "")
                                    .font(.custom(MyFont.font, size: 18))
                                    .tag(category.title ?? "")
                                    
                            }
                        }
                        .pickerStyle(.wheel)
                })
                .padding(.top, 5)
                
                HStack(spacing: 12) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Todo Date")
                            .font(.custom(MyFont.font, size: 12))
                            .foregroundStyle(.gray)
                        
                        DatePicker("", selection: $todoDate)
                            .datePickerStyle(.compact)
                            .scaleEffect(0.9, anchor: .leading)
                            .font(.custom(MyFont.font, size: 18))
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 20)
                }
                Spacer(minLength: 0)
                
                Button(action: {
                    print("here: " + (categories[0].title ?? "") + " == " + selectedCategory)
                    for i in categories.indices {
                        if (categories[i].title ?? "") == selectedCategory {
                            print("before")
                            let newTodo = Todo(context: moc)
                            newTodo.id = UUID()
                            newTodo.title = todoTitle
                            newTodo.caption = todoCaption
                            newTodo.date = todoDate
                            newTodo.tint = todoColor
                            newTodo.isCompleted = false
                            categories[i].addToTodos(newTodo)
                            try? moc.save()
                            print("here")
                            print(dataController.getTodos(from: categories[i]))
                        }
                    }
                    dismiss()
                    
                }, label: {
                    Text("Create Todo")
                        .font(.custom(MyFont.font, size: 24))
                        .fontWeight(.semibold)
                        .hSpacing(.center)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(Color("TodoColor2"))
                        .cornerRadius(20)
                })
                .opacity(todoTitle == "" ? 0.5 : 1)
            }
            else {
                NewCategorie(categories: categories)
            }
        }
        .onAppear {
            if categories.count > 0 {
                selectedCategory = categories[0].title ?? ""
            }
        }
        .padding(15)
        .background(Color("BackgroundColor"))
    }
}

