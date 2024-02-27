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
    @Binding var indexTaskToEdit: Int
    @Binding var indexCategoryToEdit: Int
    
    @Binding var editTask: Bool
    
    @State private var categoryIndex: Int = 0
    
    @Environment(\.managedObjectContext) var moc
    
    //@FetchRequest(entity: Categorie.entity(), sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var categories: FetchedResults<Categorie>
    
    var categories: FetchedResults<Categorie>
    
    @EnvironmentObject var dataController: DataManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Circle()
                .fill(todo.isCompleted ? .green : .black)
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: todo.isCompleted ? "checkmark" : "circle")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                if let index = (categories[categoryIndex].todos?.allObjects as! [Todo]).firstIndex(where: {$0.id == todo.id}) {
                                    todo.objectWillChange.send()
                                    dataController.updateIsCompleted(for: todo)
                                }
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(todo.title ?? "")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Label("\((todo.date ?? Date()).format("MMM dd, yyyy"))", systemImage: "calendar")
                        Label("\((todo.date ?? Date()).format("HH:mm"))", systemImage: "clock")
                    }
                    .font(.system(size: 13))
                    
                }
                .hSpacing(.leading)
                .padding(.bottom, todo.caption == "" ? 0 : 3)
                
                if todo.caption != "" {
                    Text(todo.caption ?? "")
                        .font(.system(size: 15))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: todo.tint ?? "").opacity(0.5))
            .cornerRadius(20)
            .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
            
            .contextMenu {
                
                Button(action: {
                    /*
                    if let index = categories[categoryIndex].tasks.firstIndex(where: { $0.id == todo.id }) {
                            // Remove the task from the array
                            self.indexTaskToEdit = index
                        }
                    */
                    if let index = (categories[categoryIndex].todos?.allObjects as! [Todo]).firstIndex(where: {$0.title == todo.title}) {
                        self.indexTaskToEdit = index
                        self.indexCategoryToEdit = categoryIndex
                    }
                    editTask.toggle()

                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation {
                            /*
                            if let index = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
                                    // Remove the task from the array
                                    categories[categoryIndex].todos.remove(at: index)
                                }
                             */
                            if let index = (categories[categoryIndex].todos?.allObjects as! [Todo]).firstIndex(where: {$0.id == todo.id}) {
                                dataController.delete(todo: todo, from: categories[categoryIndex])
                            }
                        }
                    }
                    
                    
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            }
             
        }
        .padding(.horizontal)
        .onAppear {
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                    // Remove the task from the array
                    categoryIndex = index
                }
        }
        
    }
     
}
     

#Preview {
    MainView()
}
