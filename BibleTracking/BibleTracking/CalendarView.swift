
import SwiftUI

struct CalendarView: View {
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var selectedMonth = 0 // 0 = Jan
    
    // Mock Current Year for the demo path
    let currentYear = 2026
    
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Month Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<months.count, id: \.self) { index in
                                    Button(action: { selectedMonth = index }) {
                                        Text(months[index])
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedMonth == index ? Color.blue : Color.white.opacity(0.1))
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Calendar Grid
                        VStack(spacing: 12) {
                            // Days Header
                            LazyVGrid(columns: columns) {
                                ForEach(days, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Days Content
                            LazyVGrid(columns: columns, spacing: 10) {
                                let daysInMonth = getDaysInMonth(month: selectedMonth, year: currentYear)
                                let startOffset = getStartDay(month: selectedMonth, year: currentYear)
                                
                                // Empty slots
                                ForEach(0..<startOffset, id: \.self) { _ in
                                    Color.clear.aspectRatio(1, contentMode: .fit)
                                }
                                
                                // Real Days
                                ForEach(1...daysInMonth, id: \.self) { day in
                                    let dateStr = String(format: "%04d-%02d-%02d", currentYear, selectedMonth + 1, day)
                                    // Mock Finding Logic - In real app, match ReadingPlan.fullPlan.date
                                    let hasReading = true 
                                    
                                    Button(action: {
                                        print("Selected day: \(day)")
                                    }) {
                                        VStack {
                                            Text("\(day)")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            // Tiny Reading Text (Mock)
                                            Text("Gen 1-3")
                                                .font(.system(size: 8))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Today's Reading Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Reading")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text("Genesis 1-3") // Placeholder
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Creation & The Fall")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Calendar Helpers
    func getDaysInMonth(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month + 1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func getStartDay(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month + 1, day: 1)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return calendar.component(.weekday, from: date) - 1 // 0-based result
    }
}
