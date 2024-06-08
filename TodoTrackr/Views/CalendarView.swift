//
//  CalendarView.swift
//  TodoTrackr
//
//  Created by GuiFlam on 2024-04-28.
//

import SwiftUI

struct CalendarView: View {
    @State var currentDate = Date()
    @State var currentMonth: Int = 0
    @State var isFound = false
    @State var todos: [Todo] = []
    var categories: FetchedResults<Categorie>
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 35) {
                let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(extractData()[0])
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(extractData()[1])
                            .font(.custom(MyFont.font, size: 30))
                    }
                    Spacer()
                    
                    Button(action: {
                        print("Previous month")
                        withAnimation {
                            currentMonth -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                    }
                    
                    Button(action: {
                        print("Next month")
                        withAnimation {
                            currentMonth += 1
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                    }
                }
                .padding(.horizontal)
                
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.custom(MyFont.font, size: 16))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(extractDate()) { value in
                        VStack {
                            if value.day != -1 {
                            
                                if let todo = todos.first(where: {
                                    todo in
                                    return isSameDay(date: todo.date!, date2: value.date)
                                }) {
                                    Button(action: {
                                        withAnimation {
                                            currentDate = value.date
                                        }
                                       
                                    }, label: {
                                        VStack {
                                            Text(String(value.day))
                                                .font(.custom(MyFont.font, size: 18))
                                                .foregroundStyle(isSameDay(date: value.date, date2: Date()) ? Color("TodoColor2") : .white)
                                            Spacer()
                                            Circle()
                                                .fill(.white)
                                                .frame(width: 8, height: 8)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color("TodoColor2"), lineWidth: 1.5)
                                                .frame(width: 45, height: 65)
                                        )
                                        
                                    })
                                    
                                }
                                else {
                                    Button(action: {
                                        withAnimation {
                                            currentDate = value.date
                                        }
                                    }) {
                                        VStack {
                                            Text(String(value.day))
                                                .font(.custom(MyFont.font, size: 18))
                                                .font(.title3.bold())
                                                .foregroundStyle(isSameDay(date: value.date, date2: Date()) ? Color("TodoColor2") : .white)
                                                //.brightness(100)
                                            Spacer()
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color("TodoColor2"), lineWidth: 1.5)
                                                .frame(width: 45, height: 65)
                                        )
                                    }
                                }
                                
                                
                            }
                            
                        }
                        .padding(.vertical, 8)
                        .frame(height: 60, alignment: .top)
                    }
                }
                VStack {
                    ForEach(todos, id: \.self) { todo in
                        if isSameDay(date: todo.date!, date2: currentDate) {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Spacer()
                                    Text(todo.categorie?.title ?? "")
                                        .font(.custom(MyFont.font, size: 20)).bold().underline()
                                    Spacer()
                                }
                                Spacer()
                                HStack {
                                    Text(todo.title ?? "")
                                        .font(.custom(MyFont.font, size: 18)).bold()
                                        
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 5) {
                                        Label("\((todo.date ?? Date()).format("HH:mm"))", systemImage: "clock")
                                    }
                                    .font(.custom(MyFont.font, size: 13))
                                }
                                .hSpacing(.leading)
                                .padding(.bottom, todo.caption == "" ? 0 : 3)
                                
                            }
                            .frame(width: 275, height: 65)
                            .padding()
                            .background(Color("TodoColor2"))
                            .cornerRadius(20)
                            .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                                        )
                        }
                    }
                }
            }
        }
        .background(Color("BackgroundColor"))
        .onChange(of: currentMonth) { _ in
            print("Month changed")
            
            currentDate = getCurrentMonth()
        }
        .onAppear {
            currentDate = Date()
            todos = []
                
                
                for i in categories.indices {
                    let todos = (categories[i].todos?.allObjects as! [Todo])
                    for i in todos.indices {
                        self.todos.append(todos[i])
                    }
                }
            
        }
        .navigationTitle("Calendar")
        
    }
    
    
    func isSameDay(date: Date, date2: Date)->Bool {
        let calendar = Calendar.current
        
        return calendar.isDate(date, inSameDayAs: date2)
    }
    
    func extractData()->[String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()->Date {
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .month, value: currentMonth, to: Date())!
    }
    
    func extractDate() -> [DateValue] {
        
        let calendar = Calendar.current
        guard let currentMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: Date()) else {
            return []
        }
        
        var days =  currentMonth.getAllDates().compactMap {
            date -> DateValue in
            
            let day = calendar.component(.day, from: date)
            
            return DateValue(date: date, day: day)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<(firstWeekday - 1) {
            days.insert(DateValue(date: Date(), day: -1), at: 0)
        }
        
        return days
    }
}

extension Date {
    func getAllDates()->[Date] {
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        
        var range = calendar.range(of: .day, in: .month, for: startDate)!
        range.removeLast()
        
        return range.compactMap { day -> Date in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startDate)
            
            return date!}
    }
}




