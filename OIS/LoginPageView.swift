//
//  ContentView.swift
//  OIS
//
//  Created by root user on 14.03.2021.
//

import SwiftUI
import SwiftSoup
import WebKit
import RealityKit
import ARKit

let lightGreyColor = Color(red: 239.0/255.0, green: 243.00/255.0, blue: 244.0/255.0)

let darkRedColor = Color(red: 0.72, green: 0.07, blue: 0.20)

struct LoginPageView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    func tryLogin() {
        let myURLString = "https://ois2.tlu.ee/tluois/!uus_ois2.ois_public.page?_page=9A46066693F9020547B19035E345EAEE&p_type=ois&p_user=\(username)&p_pwd=\(password)&p_mobiil=big&p_mobiil_tel="
        
        guard let myURL = URL(string: myURLString) else { return }
            
        do {
            let myHTMLString = try! String(contentsOf: myURL, encoding: .utf8)
            let htmlContent = myHTMLString
            do {
                let doc: Document = try SwiftSoup.parse(htmlContent)
                do {
                    let htmlParsed = try doc.select("input").first()!
                    
                    let authSuccText = try! htmlParsed.attr("name")
                    
                    //print (authSuccText as Any)
                    
                    if (authSuccText == "p_kasutaja_tk_str_id") {
                        if (authenticationDidFail == true){
                            authenticationDidFail = false
                        }
                        authenticationDidSucceed = true
                    }
                    else {
                        if (authenticationDidSucceed == true){
                            authenticationDidSucceed = false
                        }
                        authenticationDidFail = true
                    }
                }
            }
            //print(myHTMLString)
        } catch let error {
            print("Error: \(error)")
        }
        
    }
    
    var body: some View {
        NavigationView{
        ZStack{
            VStack{
                Logo()
                HelloText()
                UsernameTextField(username: $username)
                PasswordSecureField(password: $password)
                
                if authenticationDidFail{
                    Text("Vale kasutajanimi või parool!")
                        .offset(y: -10)
                        .foregroundColor(darkRedColor)
                }
                
                Button(action: { self.tryLogin()}) {
                    LoginButtonContent()
                }
                NavigationLink (destination: PageCamera()){
                    Text("Kaamera")
                }
                NavigationLink(destination: PageAR()){
                    Text("Liitreaalsus")
                }
            }
            .padding()
            if authenticationDidSucceed{
                Text("Sisselogimine õnnestus!")
            }
        }
        }
    }
}

struct HelloText: View {
    var body: some View {
        VStack{
            Text("Tere tulemast!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
        }
    }
}

struct Logo: View {
    var body: some View {
        Image("TLU_logo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 155, height: 30,alignment:/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipped()
            .padding(.bottom, 10)
    }
}

struct UsernameTextField: View {
    
    @Binding var username: String
    
    var body: some View {
        TextField("KASUTAJANIMI", text: $username)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            .disableAutocorrection(true)
    }
}

struct PasswordSecureField: View {
    
    @Binding var password: String
    
    var body: some View {
        SecureField("SALASÕNA", text: $password)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("LOGI SISSE")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(darkRedColor)
            .cornerRadius(35.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView()
    }
}

struct PageCamera: View{
    
    @State var image: Image? = nil
    @State var showCaptureImageView: Bool = false
    
    var body: some View{
        ZStack{
            VStack{
                Button(action: {self.showCaptureImageView.toggle()}, label: {
                    Text("Vali pilti")
                })
                image?.resizable()
                    .frame(width: 250, height: 250)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            }
            if (showCaptureImageView) {
                CaptureImageView(isShown: $showCaptureImageView, image: $image)
            }
        }
    }
}


struct CaptureImageView {
    /// MARK: - Properties
   @Binding var isShown: Bool
   @Binding var image: Image?
   
   func makeCoordinator() -> Coordinator {
     return Coordinator(isShown: $isShown, image: $image)
   }
}
extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        //picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
            context: UIViewControllerRepresentableContext<CaptureImageView>) {
        
    }
}

struct PageAR: View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: String?
    @State private var modelConfirmedForPlacement: String?
    
    var models: [String] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [String] = []
        for filename in files where filename.hasSuffix("usdz"){
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            availableModels.append(modelName)
        }
        
        return availableModels
    }()
    
    var body: some View{
        ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        
        //The actual real device is supposed to be selected for this to work
        //Otherwise you will get error: Value of type "ARView" has no member "session"
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelConfirmedForPlacement{
            print("Debug: adding model to scene - \(modelName)")
            
            let filename = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: filename)
            //Also needs real device
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30){
                ForEach(0 ..< self.models.count) { index in
                    Button(action: {
                        print("Debuf: selected model with name:\(self.models[index])")
                        
                        self.selectedModel = self.models[index]
                        
                        self.isPlacementEnabled = true
                    }){
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }.buttonStyle (PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonsView: View{
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: String?
    @Binding var modelConfirmedForPlacement: String?
    
    var body: some View{
        HStack{
            //Cancel Button
            Button(action: {
                print("DEBUG: cancel model placement")
                
                self.resetPlacementParameters()
            }){
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            //Confirm button
            Button(action: {
                print("DEBUG: confirm model placement")
                
                self.modelConfirmedForPlacement = self.selectedModel
                
                self.resetPlacementParameters()
            }){
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    func resetPlacementParameters(){
        self.isPlacementEnabled = true
        self.selectedModel = nil
    }
}
