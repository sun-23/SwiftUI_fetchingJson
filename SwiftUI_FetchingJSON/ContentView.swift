//
//  ContentView.swift
//  SwiftUI_FetchingJSON
//
//  Created by sun on 16/7/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import SwiftUI
import Combine

struct foodData:Decodable {
    
    let NameFood:String
    let Price:String
    let ImagePath:String
    let Detail:String
    
}

class NetworkManager: BindableObject {
    var didChange = PassthroughSubject<NetworkManager, Never>()
    
    var arrdata = [foodData]() {
        didSet {
            didChange.send(self)
        }
    }
    
    init() {
        guard let url = URL(string: "https://www.androidthai.in.th/ssm/getAllDatafoodTABLE.php") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let data = data else { return }
            
            let arrdata = try! JSONDecoder().decode([foodData].self, from: data)
            DispatchQueue.main.async {
                self.arrdata = arrdata
            }
            print(arrdata)
            print("completed fetching json")
            
            }.resume()
    }
}

struct ContentView : View {
    
    @State var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List (
                networkManager.arrdata.identified(by: \.NameFood)
            ) { food in
               
                NavigationButton(destination: detailView(food: food)) {
                     row(food: food)
                }
                
            }.navigationBarTitle(Text("Manu"))
        }

    }
}

struct row: View {
    
    let food : foodData

    var body: some View {
        
        VStack(alignment: .leading) {
            ImageViewWidget(ImagePath: String(food.ImagePath))
                HStack {
                    Text(food.NameFood)
                     Spacer()
                    Text(food.Price + " บาท")
                    
                }.padding()
        }
    }
    
}

struct detailView: View {
    
    let food : foodData
    
    var body : some View {
        
        VStack(alignment: .leading) {
            ImageViewWidget(ImagePath: String(food.ImagePath))
            HStack {
                Text(food.NameFood)
                Spacer()
                Text(food.Price + " บาท")
                }
            Text(food.Detail).lineLimit(10)
            Spacer()
        }.padding()
    }
}



class ImageLoader: BindableObject {
    var didChange = PassthroughSubject<Data, Never>()
    
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(ImagePath: String) {
        // fetch image data and then call didChange
        guard let url = URL(string: ImagePath) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.data = data
            }
            
            }.resume()
    }
}

struct ImageViewWidget: View {
    
    @ObjectBinding var imageLoader: ImageLoader
    
    init(ImagePath: String) {
        imageLoader = ImageLoader(ImagePath: ImagePath)
    }
    
    var body: some View {
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "Image")! : UIImage(data: imageLoader.data)!)
        //Image(uiImage: UIImage(data: imageLoader.data)!)
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
