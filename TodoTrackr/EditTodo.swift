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
    
    @Environment(\.managedObjectContext) var moc
    
    var categories: FetchedResults<Categorie>
    
    @Binding var indexTaskToEdit: Int
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
                Text("Task Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Title", text: $newTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                
                Text("Task Caption")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Caption", text: $newCaption, axis: .vertical)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.black.shadow(.drop(color: .white.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            })
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Date")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $newDate)
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
                                        .opacity(self.newColor == color ? 1 : 0)
                                })
                                .hSpacing(.center)
                                .contentShape(.rect)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        self.newColor = color
                                    }
                                }
                        }
                    }
                }
                .padding(.top, 5)
            }
            Spacer(minLength: 0)
            
            Button(action: {
                withAnimation {
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].title = self.newTitle
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].caption = self.newCaption
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].date = self.newDate
                    (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].tint = self.newColor
                    try? moc.save()
                    
                }
                dismiss()
            }, label: {
                Text("Edit Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(self.newColor == "#000000" ? .black : Color(hex:self.newColor), in: .rect(cornerRadius: 10))
            })
            .opacity(self.newTitle == "" ? 0.5 : 1)
        }
        .padding(15)
        .onAppear {
            /*
            self.newTitle = self.tasks[self.indexTaskToEdit].title
            self.newDate = self.tasks[self.indexTaskToEdit].date
            self.newCaption = self.tasks[self.indexTaskToEdit].caption
            self.newColor = self.tasks[self.indexTaskToEdit].tint
             */
            self.newTitle = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].title ?? ""
            self.newDate = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].date ?? Date()
            self.newCaption = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].caption ?? ""
            self.newColor = (categories[indexCategoryToEdit].todos?.allObjects as! [Todo])[indexTaskToEdit].tint ?? ""
            
        }
    }
}

