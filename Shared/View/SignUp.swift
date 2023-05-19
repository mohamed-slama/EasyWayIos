//
//  SignUp.swift
//  CarouselAnimated (iOS)
//
//  Created by Balaji on 28/05/21.
//

import SwiftUI

struct SignUp: View {
    @State var email = ""
    @State var username = ""
    @State var password = ""
    func register() {
        guard !email.isEmpty && !username.isEmpty && !password.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        guard isValidEmail(email) else {
            showAlert(message: "Please enter a valid email.")
            return
        }
        
        guard isValidPassword(password) else {
            showAlert(message: "Password must be at least 6 characters long.")
            return
        }
        
        // Send a POST request to your Node.js API with the user's information
        let url = URL(string: "http://127.0.0.1:8800/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                showAlert(message: error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200..<300).contains(httpResponse.statusCode) {
                showAlert(message: "Signed up successfully!")
            } else {
                showAlert(message: "Error signing up.")
            }
        }.resume()
    }

    func isValidEmail(_ email: String) -> Bool {
        // Use a regular expression to validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }

    var body: some View {
        VStack{
            
            Text("Sign Up")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("dark"))
                // Letter Spacing...
                .kerning(1.9)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Email And Password....
            VStack(alignment: .leading, spacing: 8, content: {
                
                Text("Email")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                TextField("ijustine@gmail.com", text: $email)
                // Increasing Font Size And Changing Text Color...
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("dark"))
                    .padding(.top,5)
                
                Divider()
            })
            .padding(.top,25)
            
            VStack(alignment: .leading, spacing: 8, content: {
                
                Text("Username")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                TextField("a1zea", text: $username)
                // Increasing Font Size And Changing Text Color...
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("dark"))
                    .padding(.top,5)
                
                Divider()
            })
            .padding(.top,20)
            VStack(alignment: .leading, spacing: 8, content: {
                
                Text("Password")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                SecureField("123456", text: $password)
                // Increasing Font Size And Changing Text Color...
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("dark"))
                    .padding(.top,5)
                
                Divider()
            })
            .padding(.top,20)
         
            
            // This line will reduce the use of unwanted hstack and spacers....
            // Try to use this and reduce the code in SwiftUI :)))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top,10)
            
            // Next Button...
            Button(action: {
                    register()
                
            }, label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("dark"))
                    .clipShape(Circle())
                // Shadow...
                    .shadow(color: Color("lightBlue").opacity(0.6), radius: 5, x: 0, y: 0)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top,10)
        }
        .padding()
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
