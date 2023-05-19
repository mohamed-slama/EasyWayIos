import SwiftUI
import Foundation
struct Login: View {
    @State var email = ""
    @State var password = ""
    @State var isMapHomeActive = false // added state variable to control navigation
    @Binding var isLoggedIn: Bool
    @State var userName: String = ""
    var onLoginSuccess: () -> Void
    @State private var isForgotPasswordActive = false
    func decodeToken(_ token: String) {
        let tokenComponents = token.components(separatedBy: ".")
        
        guard tokenComponents.count == 3,
              let payloadData = base64URLDecode(tokenComponents[1]) else {
            print("Invalid token format")
            return
        }
        
        do {
            let payload = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any]
            
            let id = payload?["id"] as? String ?? ""
            let username = payload?["username"] as? String ?? ""
            let role = payload?["role"] as? String ?? ""
            userName = username 
            // Save the values in UserDefaults
            UserDefaults.standard.set(username, forKey: "Username")
            UserDefaults.standard.set(role, forKey: "Role")
            UserDefaults.standard.set(id, forKey: "ID")
            
            print("ID: \(id)")
            print("Username: \(username)")
            print("Role: \(role)")
        } catch {
            print("Failed to decode token: \(error.localizedDescription)")
        }
    }

    func base64URLDecode(_ base64URLString: String) -> Data? {
        var base64 = base64URLString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Pad the base64 string with '=' characters until its length is divisible by 4
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        return Data(base64Encoded: base64)
    }

    func loginapi() {
        guard let url = URL(string: "http://127.0.0.1:8800/api/auth/login") else { return }
        
        // Check for empty fields
        guard !email.isEmpty && !password.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter email and password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let parameters = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                // Show alert for network error
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Network error. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let token = json?["token"] as? String {
                    // Show alert for successful login
                    DispatchQueue.main.async {
                        decodeToken(token)
                        let alert = UIAlertController(title: "Success", message: "You have been logged in.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            print("Token: \(token)")
                            self.isLoggedIn = true // Set login status to true
                            print("status :  \(isLoggedIn)")
                            self.isMapHomeActive = true // Navigate to SideView
                        }))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                } else {
                    // Show alert for incorrect email or password
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Incorrect email or password.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                // Show alert for invalid response format
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Invalid response format. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }.resume()
    }


    var body: some View {
        if isLoggedIn {
            Home(userName: userName)
            
        }
        VStack{
            
            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("dark"))
                // Letter Spacing...
                .kerning(1.9)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email And Password....
            VStack(alignment: .leading, spacing: 8, content: {
                
                Text("User Name")
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
            
            // Forget Password...
            Button(action: {
                    
                isForgotPasswordActive = true
                   }, label: {
                Text("Forgot password?")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            })
            // This line will reduce the use of unwanted hstack and spacers....
            // Try to use this and reduce the code in SwiftUI :)))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top,10)
            
                       .sheet(isPresented: $isForgotPasswordActive) {
                         ForgotPasswordView()
                       } 
            // Next Button...
            Button(action: {
                // Update the login status
                loginapi()
             
                
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
            NavigationLink(destination: sideview(userName: self.userName ), isActive: $isMapHomeActive) {
                  EmptyView()
            }
        }
        .padding()
    }
}


