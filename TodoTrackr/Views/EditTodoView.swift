//
//  NewTask.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-22.
//

import SwiftUI


struct EditTodo: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTitle: String = ""
    @State private var newCaption: String = ""
    @State private var newColor: String = "#000000"
    @State private var newDate: Date = Date()
    
    @Environment(\.managedObjectContext) private var moc
    
    var categories: FetchedResults<Categorie>
    
    @Binding var indexTodoToEdit: Int
    @Binding var indexCategoryToEdit: Int
    
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
                    .font(.custom(MyFont.font, size: 12))
                    .foregroundStyle(.gray)
                
                TextField("Title", text: $newTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                
                Text("Todo Caption")
                    .font(.custom(MyFont.font, size: 12))
                    .foregroundStyle(.gray)
                
                TextField("Caption", text: $newCaption, axis: .vertical)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Todo Date")
                        .font(.custom(MyFont.font, size: 12))
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $newDate)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                }
                .padding(.top, 5)
                .padding(.trailing, 20)
            }
            Spacer(minLength: 0)
            
            Button(action: {
                withAnimation {
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].title = self.newTitle
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].caption = self.newCaption
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].date = self.newDate
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].tint = self.newColor
                    try? moc.save()
                }
                dismiss()
            }, label: {
                Text("Edit Todo")
                    .font(.custom(MyFont.font, size: 24))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color("TodoColor2"))
                    .cornerRadius(20)
            })
            .opacity(self.newTitle == "" ? 0.5 : 1)
        }
        .padding(15)
        .onAppear {
            self.newTitle = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].title ?? ""
            self.newDate = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].date ?? Date()
            self.newCaption = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].caption ?? ""
            self.newColor = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTodoToEdit].tint ?? ""
        }
        .background(Color("BackgroundColor"))
    }
}

