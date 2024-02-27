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
    
    @Environment(\.managedObjectContext) var moc
    
    var categories: FetchedResults<Categorie>
    
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
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Todo Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Title", text: $todoTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                
                Text("Todo Caption")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Caption", text: $todoCaption, axis: .vertical)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.title ?? "")
                                .tag(category.title ?? "")
                        }
                    }
                    .pickerStyle(.wheel)
            })
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $todoDate)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                }
                .padding(.top, 5)
                .padding(.trailing, -15)
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Color")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    let colors: [String] = [
                        "#FFFF00", "#0000FF", "#00FF00", "#800080"
                    ]
                    
                    HStack(spacing: 0) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 20, height: 20)
                                .background(content: {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .opacity(todoColor == color ? 1 : 0)
                                })
                                .hSpacing(.center)
                                .contentShape(.rect)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        todoColor = color
                                    }
                                }
                        }
                    }
                }
                .padding(.top, 5)
            }
            Spacer(minLength: 0)
            
            Button(action: {
                for i in categories.indices {
                    if (categories[i].title ?? "") == selectedCategory {
                        let newTodo = Todo(context: moc)
                        newTodo.title = todoTitle
                        newTodo.caption = todoCaption
                        newTodo.date = todoDate
                        newTodo.tint = todoColor
                        categories[i].addToTodos(newTodo)
                        try? moc.save()
                    }
                }
                dismiss()
            }, label: {
                Text("Create Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(todoColor == "#000000" ? Color(hex:"#111111") : Color(hex: todoColor), in: .rect(cornerRadius: 10))
            })
            .opacity(todoTitle == "" ? 0.5 : 1)
        }
        .padding(15)
    }
}

