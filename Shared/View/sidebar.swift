//
//  ContentView.swift
//  Custom Slide Out Menu
//
//  Created by Kavsoft on 27/03/20.
//  Copyright © 2020 Kavsoft. All rights reserved.
//

import SwiftUI
import CodeScanner
import PDFKit
struct sideview: View {
    @State var index = "Home"
    @State var show = false
    var userName: String
    @State private var navigateToHome = false
  
    @Environment(\.presentationMode) var presentationMode
    var userRole: String {
          UserDefaults.standard.string(forKey: "Role") ?? ""
      }
    var body: some View {
        ZStack {
            (self.show ? Color.black.opacity(0.05) : Color.clear).edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 25) {
                    HStack(spacing: 15) {
                        Image("pic")
                            .resizable()
                            .frame(width: 65, height: 65)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(self.userName)
                                .fontWeight(.bold)
                            
                            Text("New York, US")
                        }
                    }
                    .padding(.bottom, 50)
                    
                    ForEach(data, id: \.self) { i in
                        if userRole != "user" || i != "ScanQr" {
                            Button(action: {
                                self.index = i
                                withAnimation(.spring()) {
                                    self.show.toggle()
                                }
                            }) {
                                HStack {
                                    Capsule()
                                        .fill(self.index == i ? Color.orange : Color.clear)
                                        .frame(width: 5, height: 30)
                                    
                                    Text(i)
                                        .padding(.leading)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }

                    
                    Spacer()
                    
                    Button(action: {
                        // Perform logout API request
                        
                        guard let url = URL(string: "http://localhost:8800/api/auth/logout") else {
                            return
                        }
                        
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let error = error {
                                print("Error: \(error)")
                                // Handle error cases and update UI accordingly
                            } else if let response = response as? HTTPURLResponse {
                                if response.statusCode == 200 {
                                    // Logout successful
                                    DispatchQueue.main.async {
                                        navigateToHome = true
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                } else {
                                    // Handle error cases and update UI accordingly
                                    print("Error: \(response.statusCode)")
                                }
                            }
                        }
                        
                        task.resume()
                    }) {
                        Text("Logout")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding(.leading)
                .padding(.top)
                .scaleEffect(self.show ? 1 : 0)
                
                ZStack(alignment: .topTrailing) {
                    MainView(show: self.$show, index: self.$index,userRole: userRole)
                        .scaleEffect(self.show ? 0.8 : 1)
                        .offset(x: self.show ? 150 : 0, y: self.show ? 50 : 0)
                        .disabled(self.show ? true : false)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            self.show.toggle()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .opacity(self.show ? 1 : 0)
                }
            }
        }
        .background(
            NavigationLink(destination: Home(userName: ""), isActive: $navigateToHome) { EmptyView() }
        )
    }
}




struct MainView : View {
    @Binding var show: Bool
    @Binding var index: String
    var userRole: String

    @State private var isLoading: Bool = false // State variable to control loader visibility

    @State private var isRefreshing: Bool = false // State variable to control refresh action

    var body : some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            self.show.toggle()
                        }
                    }) {
                        Image("Menu")
                            .resizable()
                            .frame(width: 20, height: 15)
                            .foregroundColor(.black)
                    }

                    Spacer()

                    Button(action: {
                        // Additional button action code
                    }) {
                        Image("menudot")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.black)
                    }
                }

                Text("EasyWAY")
                    .fontWeight(.bold)
                    .font(.title)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            ZStack {
                homee().opacity(self.index == "Home" ? 1 : 0)
                track().opacity(self.index == "track" ? 1 : 0)
                Mytickets(userID: UserDefaults.standard.string(forKey: "ID") ?? "")
                    .opacity(self.index == "My tickets" ? 1 : 0)
                Settings().opacity(self.index == "ScanQr" ? 1 : 0)

                if isLoading {
                    ProgressView() // Loader
                        .padding(.vertical)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .onAppear {
                // Show loader and fetch data here
                isLoading = true
                fetchData()
            }
            .overlay(
                GeometryReader { geometry in
                    if isRefreshing {
                        ProgressView()
                            .frame(width: geometry.size.width, height: 40)
                            .position(x: geometry.size.width / 2, y: -20)
                    }
                }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 100 && !isRefreshing {
                            isRefreshing = true
                            isLoading = true
                            fetchData()
                        }
                    }
                    .onEnded { _ in
                        // Reset the refresh state
                        isRefreshing = false
                    }
            )
        }

        func fetchData() {
            // Simulated async network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Mock data fetch completed
                isLoading = false
                isRefreshing = false
            }
        }
    }



struct homee : View {
    
    var body : some View{
        
ticketview() 
    }
}

struct track : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Homemp()
            }
        }
    }
}
struct Mytickets: View {
    let userID: String

    @State private var seatNumbers: [Int] = []

    @State private var reservations: [SeatResponse] = []

     var body: some View {
         GeometryReader { _ in
            ScrollView {
             VStack(alignment: .leading, spacing: 0) {
                 HStack {
                     VStack(alignment: .leading, spacing: 4) {
                         Text("BUS")
                             .font(.headline)
                             .fontWeight(.semibold)
                         Text("a502")
                             .font(.headline)
                             .fontWeight(.semibold)
                     }
                     Spacer()
                     Image(systemName: "barcode.viewfinder")
                         .font(.largeTitle)
                         .foregroundColor(.gray)
                 }
                 .padding(.horizontal)
                 .padding(.top)

                 Divider()
                     .padding(.horizontal)

                 ForEach(reservations, id: \._id) { reservation in
                     HStack {
                         VStack(alignment: .leading, spacing: 4) {
                             Text("Seat PASS")
                                 .font(.system(size: 22))
                                 .fontWeight(.bold)
                             Text("PASSENGER NAME")
                                 .font(.headline)
                                 .foregroundColor(Color.gray)
                             Text(UserDefaults.standard.string(forKey: "Username") ?? "")
                                 .font(.title)
                                 .fontWeight(.bold)
                                 .foregroundColor(Color.black)
                                 .padding(.bottom, 10)
                             Text("FROM")
                                 .font(.headline)
                                 .foregroundColor(Color.gray)
                             Text("Tunis")
                                 .font(.title)
                                 .fontWeight(.bold)
                                 .foregroundColor(Color.black)
                                 .padding(.bottom, 10)
                             Text("TO")
                                 .font(.headline)
                                 .foregroundColor(Color.gray)
                             Text("ariana")
                                 .font(.title)
                                 .fontWeight(.bold)
                                 .foregroundColor(Color.black)
                                 .padding(.bottom, 10)
                         }
                         Spacer()
                         VStack(alignment: .trailing, spacing: 4) {
                             Text("DATE")
                                 .font(.headline)
                                 .foregroundColor(Color.gray)
                             Text("12 MAY, 2023")
                                 .font(.title)
                                 .fontWeight(.bold)
                                 .foregroundColor(Color.black)
                                 .padding(.bottom, 10)

                             Text("SEAT")
                                 .font(.headline)
                                 .foregroundColor(Color.gray)
                             if reservation.seatNumbers.isEmpty {
                                 Text("Loading...")
                                     .font(.title)
                                     .fontWeight(.bold)
                                     .foregroundColor(.black)
                                     .padding(.bottom, 10)
                             } else {
                                 ForEach(reservation.seatNumbers, id: \.self) { seatNumber in
                                     Text("Seat \(seatNumber)")
                                         .font(.title)
                                         .fontWeight(.bold)
                                         .foregroundColor(.black)
                                         .padding(.bottom, 10)
                                 }
                             }
                         }
                     }
                     .padding(.horizontal)
                     .padding(.vertical)

                     Divider()
                         .padding(.horizontal)

                     HStack {
                         Text("Mobile Seat Pass")
                             .font(.system(size: 18))
                             .foregroundColor(Color.white)
                             .padding(.horizontal, 20)
                             .padding(.vertical, 10)
                             .background(Color.blue)
                             .cornerRadius(10)
                         Spacer()
                     }
                     .padding(.horizontal)
                     .padding(.bottom)
                 }
             }
             .background(Color.white)
             .cornerRadius(16)
             .shadow(radius: 4)
            
         
            }
         } .onAppear {
            fetchSeatNumbers(userId: UserDefaults.standard.string(forKey: "ID") ?? "")
         }
     }
    struct SeatResponse: Codable {
        let _id: String
        let seatNumbers: [Int]
        let __v: Int

        private enum CodingKeys: String, CodingKey {
            case _id
            case seatNumbers = "Seatnumbers"
            case __v
        }
    }


    func fetchSeatNumbers(userId: String) {
        guard let url = URL(string: "http://127.0.0.1:8800/api/reservation/reservations/\(userId)") else {
            // Handle invalid URL
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle the response and error
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let reservations = try decoder.decode([SeatResponse].self, from: data)
                let seatNumbers = reservations.flatMap { $0.seatNumbers }
                print("Reservations fetched successfully: \(seatNumbers)")
                
                DispatchQueue.main.async {
                    self.reservations = reservations
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }





}

struct Settings: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String = "Scan a QR Code to get started"
    @State var selectedSeats: [String]?
    @State var ticketPrice: Double?
    @State var isTicketDownloaded = false
    
    var scannerSheet: some View {
        CodeScannerView(codeTypes: [.qr], completion: { result in
            switch result {
            case .success(let code):
                let qrCodeData = code.string.data(using: .utf8) ?? Data()
                if let qrCodeDict = try? JSONSerialization.jsonObject(with: qrCodeData, options: []) as? [String: Any],
                   let seats = qrCodeDict["seats"] as? [String],
                   let price = qrCodeDict["price"] as? Double {
                    self.selectedSeats = seats
                    self.ticketPrice = price
                } else {
                    let scannedText = code.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    let components = scannedText.components(separatedBy: "\n")
                    if let seatsComponent = components.first(where: { $0.hasPrefix("Selected Seats:") }),
                       let priceComponent = components.first(where: { $0.hasPrefix("Price:") }),
                       let seats = seatsComponent.components(separatedBy: ":").last?
                                    .replacingOccurrences(of: "[", with: "")
                                    .replacingOccurrences(of: "]", with: "")
                                    .components(separatedBy: ", "),
                       let price = Double(priceComponent.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") {
                        self.selectedSeats = seats
                        self.ticketPrice = price
                    } else {
                        print("Invalid QR code format")
                    }
                }
                self.scannedCode = code.string
                self.isPresentingScanner = false
            case .failure(let error):
                print("Scanning failed: \(error.localizedDescription)")
            }
        })
    }
   
    
    var body: some View {
        GeometryReader{_ in
            VStack {
                Text("Boarding Ticket")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                if let seats = self.selectedSeats, let price = self.ticketPrice {
                    
                    VStack(alignment: .leading, spacing: 0) {
                           HStack {
                               VStack(alignment: .leading, spacing: 4) {
                                   Text("BUS")
                                       .font(.headline)
                                       .fontWeight(.semibold)
                                   Text("a502")
                                       .font(.headline)
                                       .fontWeight(.semibold)
                               }
                               Spacer()
                               Image(systemName: "barcode.viewfinder")
                                   .font(.largeTitle)
                                   .foregroundColor(.gray)
                           }
                           .padding(.horizontal)
                           .padding(.top)
                           
                           Divider()
                               .padding(.horizontal)
                           
                           HStack {
                               VStack(alignment: .leading, spacing: 4) {
                                   Text("Seat PASS")
                                       .font(.system(size: 22))
                                       .fontWeight(.bold)
                                   Text("PASSENGER NAME")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("Mohamed slama")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                                   Text("FROM")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("Tunis")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                                   Text("TO")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("ariana")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                               }
                               Spacer()
                               VStack(alignment: .trailing, spacing: 4) {
                                   Text("DATE")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("12 MAY, 2023")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                                   
                                   Text("SEAT")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("\(seats.joined(separator: ", "))")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                                   Text("price")
                                       .font(.headline)
                                       .foregroundColor(Color.gray)
                                   Text("\(price, specifier: "%.2f") $")
                                       .font(.title)
                                       .fontWeight(.bold)
                                       .foregroundColor(Color.black)
                                       .padding(.bottom, 10)
                               }
                           }
                           .padding(.horizontal)
                           .padding(.vertical)
                           
                           Divider()
                               .padding(.horizontal)
                           
                           HStack {
                               Text("Mobile Seat  Pass")
                                   .font(.system(size: 18))
                                   .foregroundColor(Color.white)
                                   .padding(.horizontal, 20)
                                   .padding(.vertical, 10)
                                   .background(Color.blue)
                                   .cornerRadius(10)
                               Spacer()
                               
                               Button(action: {
                                   // handle download action
                               }) {
                                   Image(systemName: "arrow.down.circle.fill")
                                       .font(.title)
                                       .foregroundColor(.blue)
                               }
                           }
                           .padding(.horizontal)
                           .padding(.bottom)
                       }
                       .background(Color.white)
                       .cornerRadius(16)
                       .shadow(radius: 4)

                } else {
                    HStack {
                        Spacer()
                        Text(scannedCode)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.vertical, 20)
                        Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                        Spacer()
                    }
                    Button(action: {
                             self.isPresentingScanner = true
                         }) {
                             Text("Scan QR Code")
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .padding()
                                 .background(Color.blue)
                                 .cornerRadius(10)
                         }
                         .sheet(isPresented: $isPresentingScanner) {
                             scannerSheet
                         }
                    
                }
                Spacer()
            }
            .padding()
           
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}



struct logout : View {
    
    var body : some View{
        
        GeometryReader{_ in
            
            VStack{
                
                Text("Help")
            }
        }
    }
}


var data = ["Home","track","My tickets","ScanQr"]
