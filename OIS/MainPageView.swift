//
//  SwiftUIView.swift
//  OIS
//
//  Created by root user on 14.03.2021.
//

import SwiftUI


struct MainPageView: View {
    
    
    @State var selectedIndex = 0
    
    let darkRedColor = Color(red: 0.72, green: 0.07, blue: 0.20)
    
    let lightGreyColor = Color(red: 0.58, green: 0.59, blue: 0.69)
    
    
    let tabBarImageNames = ["list.bullet.rectangle", "calendar.badge.clock", "eyeglasses", "message", "star"]
    
    var body: some View {
        
        VStack {
            
            ZStack {
                switch selectedIndex {
                case 0:
                    NavigationView{
                        VStack{
                            HStack{
                                LessonsShortView()
                            }
                            HStack{
                                LatestGradesView()
                            }
                        }
                        .navigationTitle("Avaleht")
                    }
                    
                case 1:
                    NavigationView{
                        Text("Tunniplaan")
                            .navigationTitle("Minu tunniplaan")
                    }
                    
                case 2:
                    NavigationView{
                        Text("Õpingukava")
                            .navigationTitle("Minu õpingukava")
                    }
                    
                case 3:
                    NavigationView{
                        Text("Teated")
                            .navigationTitle("Teated")
                    }
                    
                case 4:
                    NavigationView{
                        Text("Õppetulemused")
                            .navigationTitle("Õppetulemused")
                    }
                    
                default:
                    NavigationView{
                        Text("Reamaining tabs")
                    }
                }
            }
            
            Spacer()
            
            HStack {
                ForEach(0..<5) { num in
                    Button(action: {
                        selectedIndex = num
                    }, label: {
                        Spacer()
                        Image(systemName: tabBarImageNames[num])
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(selectedIndex == num ? darkRedColor : lightGreyColor)
                        Spacer()
                    })
                    
                }
            }
        }
    }
}




struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}
