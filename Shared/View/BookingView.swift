//
//  BookingView.swift
//  Movie_App (iOS)
//
//  Created by Balaji on 17/02/21.
//

import SwiftUI
import CoreImage
import EFQRCode
import MessageUI
import MailCore
import iPaymentButton
import CodeScanner
import iPaymentButton

extension UIImage {
    func saveToTempURL() throws -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        try self.pngData()?.write(to: tempURL)
        return tempURL
    }
}
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
struct BookingView: View {
    
    @State var bookedSeats: [Int] = [1,10,25,30,45,59,60]
    @State var selectedSeats : [Int] = []
    
    @State var date: Date = Date()
    @State var showAlert = false
    @State var alertMessage = ""
    @State var selectedTime = "11:30"
    @State var emailMessageBody = ""
    @State var qrCodeImage: UIImage? = nil
    @State private var tickets: [Ticket] = []
    @State private var sidebarIndex: String = "Home"
    @State private var showSidebar: Bool = false
 
    @Environment(\.presentationMode) var presentaion
    let kBookedSeatsKey = "BookedSeats"
    init() {
        if let loadedBookedSeats = UserDefaults.standard.array(forKey: kBookedSeatsKey) as? [Int] {
            self._bookedSeats = State(initialValue: loadedBookedSeats)
        } else {
            self._bookedSeats = State(initialValue: [1,10,25,30,45,59,60])
        }
    }
    
    func generateQRCodeAndSendEmail() {
        let price = selectedSeats.count * 70 // replace 10 with the actual price of the ticket
        let text = "Selected Seats: \(selectedSeats)\nPrice: \(price)"
        
        // Generate QR Code Image
        let data = text.data(using: .ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            alertMessage = "Failed to generate QR code"
            showAlert = true
            return
        }
        filter.setValue(data, forKey: "inputMessage")
        let qrCode = filter.outputImage
        let qrCodeSize = CGSize(width: 200, height: 200)
        let context = CIContext()
        guard let qrCodeCGImage = context.createCGImage(qrCode!, from: qrCode!.extent) else {
            alertMessage = "Failed to generate QR code"
            showAlert = true
            return
        }
        let qrCodeUIImage = UIImage(cgImage: qrCodeCGImage).resized(to: qrCodeSize)
        
        // Save QR Code Image to Temporary Directory
        do {
            let qrCodeImageURL = try qrCodeUIImage.saveToTempURL()
            
            // Create MailCore Message
            let builder = MCOMessageBuilder()
            builder.header.from = MCOAddress(mailbox: "sender@example.com") // Replace with the actual sender email address
            builder.header.to = [MCOAddress(mailbox: "mohamed.slama1@esprit.tn")] // Replace with the actual recipient email address
            builder.header.subject = "Ticket of Reserved Seats "
            builder.htmlBody = emailMessageBody
            
            // Attach QR Code Image to Email
            let imageData = try Data(contentsOf: qrCodeImageURL)
            let attachment = MCOAttachment(data: imageData, filename: "qrCode.png")
            builder.addAttachment(attachment)
            
            // Set SMTP Server and Credentials
            let smtpSession = MCOSMTPSession()
            smtpSession.hostname = "smtp.gmail.com" // Replace with the actual SMTP server hostname
            smtpSession.port = 587 // Replace with the actual SMTP server port
            smtpSession.username = "mohamed.slama1@esprit.tn" // Replace with the actual sender email address
            smtpSession.password = "14769075" // Replace with the actual sender email password
            smtpSession.connectionType = .startTLS
            
            // Send Email
            let data = builder.data()
            let sendOperation = smtpSession.sendOperation(with: data)
            sendOperation?.start { error in
                if let error = error {
                    self.alertMessage = "Failed to send email: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    self.alertMessage = "Seat booked succefuly check ur Email and we wish u a good ride"
                    self.showAlert = true
                }
            }
        } catch {
            alertMessage = "Failed to save QR code image"
            showAlert = true
        }
    }


    
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false, content: {
            
            HStack{
                
                Button(action: {presentaion.wrappedValue.dismiss()}, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                })
                
                Spacer()
            }
            .overlay(
            
                Text("Select Seats")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            )
            .padding()
            
            // Curve Or Thatre View...
            
            GeometryReader{reader in
                
                // To Get Width...
                
                let width = reader.frame(in: .global).width
                
                Path{path in
                    
                    // creating simple curve...
                    path.move(to: CGPoint(x: 0, y: 50))
                    
                    path.addCurve(to: CGPoint(x: width, y: 50), control1: CGPoint(x: width / 2, y: 0), control2: CGPoint(x: width / 2, y: 0))
                }
                .stroke(Color.gray,lineWidth: 1.5)
            }
            // MaxHeight...
            .frame(height: 50)
            .padding(.top,20)
            .padding(.horizontal,35)
            
            // Grid View Of Seats...
            
            // total seats = 60..
            // Mock Or Fake Seats = 4 To Adjust Space...
            
            let totalSeats = 30 + 4
            
            let leftSide = 0..<totalSeats/2
            let rightSide = totalSeats/2..<totalSeats
            
            HStack(spacing: 30){
                
                let columns = Array(repeating: GridItem(.flexible(),spacing: 10), count: 2)
                
                LazyVGrid(columns: columns, spacing: 13, content: {

                    ForEach(leftSide,id: \.self){index in
                        
                        // Getting Correct Seat...
                        let seat = index >= 29 ? index - 1 : index
                        
                        
                        SeatView(index: index, seat: seat, selectedSeats: $selectedSeats, bookedSeats: $bookedSeats)
                            
                    }
                })
                
                LazyVGrid(columns: columns, spacing: 13, content: {

                    ForEach(rightSide,id: \.self){index in
                        
                        // Getting Correct Seat...
                        let seat = index >= 35 ? index - 2 : index - 1
                        
                        SeatView(index: index, seat: seat, selectedSeats: $selectedSeats, bookedSeats: $bookedSeats)
                    }
                })
            }
            .padding()
            .padding(.top,30)
            
            HStack(spacing: 15){
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray)
                    .frame(width: 20, height: 20)
                    .overlay(
                    
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.gray)
                    )
                
                Text("Booked")
                    .font(.caption)
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color("button"),lineWidth: 2)
                    .frame(width: 20, height: 20)
                
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("button"))
                    .frame(width: 20, height: 20)
                
                Text("Selected")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.top,25)
            
            HStack{
                
                Text("Date:")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                
                HStack(spacing: 15){
                    
                    ForEach(time,id:\ .self){timing in
                        
                        Text(timing)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .padding(.horizontal,30)
                            .background(Color("button").opacity(selectedTime == timing ? 1 : 0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                
                                selectedTime = timing
                            }
                    }
                }
                .padding(.horizontal)
            })
            
            HStack(spacing: 15){
                let price = selectedSeats.count * 70
                let isController = UserDefaults.standard.string(forKey: "Role") == "controlleur"
                let discountedPrice = isController ? price / 2 : price

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(selectedSeats.count) Seats")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if isController {
                        Text("$\(price)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .strikethrough()

                        HStack {
                            Text("$\(discountedPrice)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            Text("50% off")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    } else {
                        Text("$\(price)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }

                .frame(width: 100)
            
                iPaymentButton(type: .buy, style: .whiteOutline, action: {
                    if isController {
                        iPaymentButton.applePayDemo(price: Double(discountedPrice))
                    }
                 else {
                iPaymentButton.applePayDemo(price: Double(price))
                }
                    
                    generateQRCodeAndSendEmail()

                    for seat in selectedSeats {
                        if !bookedSeats.contains(seat) {
                            bookedSeats.append(seat)
                            UserDefaults.standard.set(bookedSeats, forKey: kBookedSeatsKey)
                            
                            let ticket = Ticket(seat: seat, passengerName: UserDefaults.standard.string(forKey: "Username") ?? "", from: "tunis", to: "ariana", date: "12 MAY, 2023")
                            tickets.append(ticket)
                            print(tickets)
                            print(seat)
                            // Prepare the request payload
                            let capturedSeat = seat
                                     let capturedPrice = price
                            let userid = UserDefaults.standard.string(forKey: "ID") ?? ""
                                     // Prepare the request payload
                                     let reservationData: [String: Any] = [
                                        "user": userid , // Replace with the user ID or appropriate user identifier
                                         "seatNumbers": [capturedSeat],
                                         "totalePrice": capturedPrice
                                     ]
                            
                            // Convert the payload to JSON data
                            let jsonData = try? JSONSerialization.data(withJSONObject: reservationData)
                            
                            // Create the request
                            let url = URL(string: "http://127.0.0.1:8800/api/reservation")!
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.httpBody = jsonData
                            
                            // Send the request
                            URLSession.shared.dataTask(with: request) { data, response, error in
                                // Handle the response and error
                                if let error = error {
                                    print("Error: \(error)")
                                    return
                                }
                                
                                if let response = response as? HTTPURLResponse {
                                    print("Response code: \(response.statusCode)")
                                    // Handle the response code
                                    if response.statusCode == 200 {
                                          print("Reservation successfully saved")
                                      } else {
                                          print("Failed to save the reservation")
                                      }
                                }
                                if let data = data {
                                     do {
                                         let json = try JSONSerialization.jsonObject(with: data, options: [])
                                         print("Response data: \(json)")
                                     } catch {
                                         print("Error decoding response data: \(error)")
                                     }
                                 }
                            }.resume()
                        }
                    }
                    selectedSeats.removeAll()
                })

            }
            .disabled(selectedSeats.isEmpty)
            .padding()
            .padding(.top,20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        })
        .background(Color("bg").ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
    
}

struct SeatView: View {
    var index: Int
    var seat: Int
    
    @Binding var selectedSeats: [Int]
    @Binding var bookedSeats: [Int]
    
    @State private var isBooked = false
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 5)
                .stroke((bookedSeats.contains(seat) || isBooked) ? Color.gray : Color("button"), lineWidth: 2)
                .frame(height: 30)
                .background(
                    selectedSeats.contains(seat) ? Color("button") : Color.clear
                )
                .opacity(index == 0 || index == 28 || index == 35 || index == 63 ? 0 : 1)
            
            if bookedSeats.contains(seat){
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if bookedSeats.contains(seat) {
                return
            }
            
            if selectedSeats.contains(seat) {
                selectedSeats.removeAll { (removeSeat) -> Bool in
                    return removeSeat == seat
                }
                
                isBooked = false // Reset the isBooked state when the user unselects a seat
            } else {
                selectedSeats.append(seat)
                isBooked = true // Set the isBooked state to true when the user selects a seat
            }
        }
        .disabled(bookedSeats.contains(seat) || isBooked || (index == 0 || index == 28 || index == 35 || index == 63))
    }
}



struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView()
    }
}
