//
//  LessonsShortView.swift
//  OIS
//
//  Created by root user on 15.03.2021.
//

import SwiftUI


struct Lesson: Identifiable {
    var id = UUID()
    var name: String
    var code: String
    var eap: Double
}

struct LessonRow: View {
    
    let darkRedColor = Color(red: 0.72, green: 0.07, blue: 0.20)

    let lightGreyColor = Color(red: 0.58, green: 0.59, blue: 0.69)
    
    var lesson: Lesson
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(lesson.name)
                Text(lesson.code).font(.subheadline).foregroundColor(lightGreyColor)
            }
            Spacer()
            Text(String(format: "%.1f EAP", lesson.eap)).font(.headline).foregroundColor(darkRedColor)
        }
    }
}

struct LessonsShortView: View {
    let studyPlan = [
        Lesson(name: "Teaduslik mõtteviis", code: "IFI6201.DT", eap: 6.0),
        Lesson(name: "Algoritmid ja andmestruktuurid", code: "IFI6228.DT", eap: 6.0),
        Lesson(name: "Tõenäosusteooria elemendid", code: "MLM6216.DT", eap: 4.0),
        Lesson(name: "Agiilne tarkvaraarendus", code: "IFI6054.DT", eap: 3.0),
        Lesson(name: "Mobiilirakenduste arendamine", code: "IFI6224.DT", eap: 4.0),
    ]
    
    var body: some View {
        List {
            Section(header: ListHeader(), footer: ListFooter()) {
                ForEach(studyPlan) { lesson in
                    LessonRow(lesson: lesson)
                }
            }
        }.listStyle(GroupedListStyle())
    }
}



struct ListHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "eyeglasses")
            Text("Õpingukava (ESITATUD)")
        }
    }
}

struct ListFooter: View {
    var body: some View {
        Text("Kokku: 23 EAP")
    }
    
}

struct LessonsShortView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsShortView()
    }
}
