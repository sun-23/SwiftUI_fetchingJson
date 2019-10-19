//
//  ContentView.swift
//  FetchJSONandImagesDemo
//
//  Created by Brian Voong on 6/8/19.
//  Copyright © 2019 Brian Voong. All rights reserved.
//

import SwiftUI
import Combine
import KingfisherSwiftUI

struct Course: Decodable {
    let name, imageUrl: String
    let number_of_lessons : Int
    
}

class NetworkManager: ObservableObject {
    
    @Published
    var courses = [Course]()
    
    func fetchCourse(){
        guard let url = URL(string: "https://api.letsbuildthatapp.com/jsondecodable/courses") else { return }
               URLSession.shared.dataTask(with: url) { (data, _, _) in
                   
                   guard let data = data else { return }
                   
                   let courses = try! JSONDecoder().decode([Course].self, from: data)
                   DispatchQueue.main.async {
                       self.courses = courses
                   }
                   
                   print(courses)
                   print("completed fetching json")
                   
               }.resume()
    }
}

struct ContentView : View {
    
    @ObservedObject var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List (
                networkManager.courses, id: \.name
            ) { course in
                
                NavigationLink(destination: CourseDetailView(course: course)) {
                CourseRowView(course: course)
                }
                
            }.navigationBarTitle(Text("Courses"),displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                print("Fetching json data")
                
                self.networkManager.fetchCourse()
                
            }, label: {
                Text("Fetch Courses")
            }))
        }
    }
}

struct CourseDetailView: View {
    
    let course : Course
    
    var body: some View {
        VStack (alignment: .leading) {
            KFImage(URL(string: course.imageUrl))
            .resizable()
            .frame(width: 320, height: 180)
            .cornerRadius(10)
            //ImageViewWidget(imageUrl: course.imageUrl)
            //            Image("apple")
            //                .resizable()
            //                .frame(width: 200, height: 200)
            //                .clipped()
                Text(course.name)
                Text("Number of lessons " + String(course.number_of_lessons) + " lessons")
                Spacer()
        }
        
    }
    
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        VStack (alignment: .leading) {
            KFImage(URL(string: course.imageUrl))
            .resizable()
            .frame(width: 320, height: 180)
            .cornerRadius(10)
            //ImageViewWidget(imageUrl: course.imageUrl)
//            Image("apple")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .clipped()
            Text(course.name)
            //Text(course.imageUrl)
        }
    }
}

class ImageLoader: ObservableObject {
    
    @Published
    var data = Data()
    
    init(imageUrl: String) {
        // fetch image data and then call didChange
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.data = data
            }
            
        }.resume()
    }
}

struct ImageViewWidget: View {
    
    @ObservedObject var imageLoader: ImageLoader
    
    init(imageUrl: String) {
        imageLoader = ImageLoader(imageUrl: imageUrl)
    }
    
    var body: some View {
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "apple")! :  UIImage(data: imageLoader.data)!)
        //Image(uiImage: imageLoader.data)
            .resizable()
            .frame(width: 320, height: 180)
            .cornerRadius(10)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
