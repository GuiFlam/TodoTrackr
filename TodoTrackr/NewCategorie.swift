//
//  NewTask.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-22.
//

import SwiftUI


struct NewCategorie: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryTitle: String = ""
    
    @Environment(\.managedObjectContext) var moc
    
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
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text("Category Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Title", text: $categoryTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                
                
            })
            .padding(.top, 5)
            
            Spacer(minLength: 0)
            
            Button(action: {
                /*
                for i in categories.indices {
                    if(categories[i].title == selectedCategory) {
                        categories[i].todos.append(Task(title: taskTitle, caption: taskCaption, date: taskDate, tint: taskColor))
                        
                    }
                }
                 */
                let id = dataController.getNextCategoryIndex()
                let categorie = Categorie(context: moc)
                categorie.id = id
                categorie.title = categoryTitle
                let array: [Todo] = []
                categorie.todos = NSSet(array: array)
                
                try? moc.save()
                
                dismiss()
            }, label: {
                Text("Create Category")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 8)
                    .background(.white)
                    .cornerRadius(20)
            })
        }
        .padding(15)
    }
    
}

