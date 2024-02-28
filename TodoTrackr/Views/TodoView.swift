//
//  TaskView.swift
//  TaskScribe
//
//  Created by GuiFlam on 2024-02-22.
//

import SwiftUI


struct TodoView: View {
    
    @ObservedObject var todo: Todo
    @ObservedObject var category: Categorie
    @Binding var indexTodoToEdit: Int
    @Binding var indexCategoryToEdit: Int
    
    @Binding var editTodo: Bool
    
    @State private var categoryIndex: Int = 0
    
    @Environment(\.managedObjectContext) var moc
    
    var categories: FetchedResults<Categorie>
    
    @EnvironmentObject var dataController: DataManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Circle()
                .fill(todo.isCompleted ? .clear : Color("BackgroundColor"))
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: todo.isCompleted ? "checkmark" : "circle")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                todo.objectWillChange.send()
                                dataController.updateIsCompleted(for: todo)
                                
                            }
                        }
                }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(todo.title ?? "")
                        .font(.custom(MyFont.font, size: 20)).bold()
                        
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Label("\((todo.date ?? Date()).format("MMM dd, yyyy"))", systemImage: "calendar")
                        Label("\((todo.date ?? Date()).format("HH:mm"))", systemImage: "clock")
                    }
                    .font(.custom(MyFont.font, size: 13))
                }
                .hSpacing(.leading)
                .padding(.bottom, todo.caption == "" ? 0 : 3)
                
                if todo.caption != "" {
                    Text(todo.caption ?? "")
                        .font(.custom(MyFont.font, size: 15))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("TodoColor2"))
            .cornerRadius(20)
            .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        )
            
            .contextMenu {
                
                Button(action: {
                    if let index = (categories[Int(category.id)].todos?.allObjects as! [Todo]).firstIndex(where: {$0.title == todo.title}) {
                        self.indexTodoToEdit = index
                        self.indexCategoryToEdit = Int(category.id)
                    }
                    editTodo.toggle()

                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation {
                            dataController.delete(todo: todo, from: categories[categoryIndex])
                        }
                    }
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
        }
        .padding(.horizontal)
        .onAppear {
            if let index = categories.firstIndex(where: { $0.title == category.title }) {
                    // Remove the task from the array
                    categoryIndex = index
                }
        }
    }
}

#Preview {
    MainView()
}
