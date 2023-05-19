import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var verificationCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isCodeVerificationActive = false
    @State private var isPasswordChangeActive = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            if isPasswordChangeActive {
                // Password change fields
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Perform password change request
                    
                    // Check if passwords match
                    guard newPassword == confirmPassword else {
                        showAlert = true
                        alertMessage = "Passwords do not match."
                        return
                    }
                    
                    // Perform API request to change the password
                    changePassword(newPassword: newPassword)
                }) {
                    Text("Change Password")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            } else if isCodeVerificationActive {
                // Code verification field
                TextField("Verification Code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Perform code verification request
                    verifyCode(email: email , code: verificationCode)
                }) {
                    Text("Verify Code")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Perform email verification request
                    sendVerificationCode()
                }) {
                    Text("Send Verification Code")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                        title: Text("Success"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"), action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    )
            
        }
    }
    
    func sendVerificationCode() {
        guard let url = URL(string: "http://localhost:8800/api/auth/sendVerificationCode") else {
            return
        }
        
        // Prepare the request body
        let parameters = ["email": email]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                // Handle the error
                return
            }
            
            // Assuming successful response, navigate to code verification screen
            DispatchQueue.main.async {
                isCodeVerificationActive = true
            }
        }.resume()
    }








    func verifyCode(email: String, code: String) {
        let url = URL(string: "http://localhost:8800/api/auth/verifycode")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "email": email,
            "code": code
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                print("Error: No response received")
                return
            }
            
            if response.statusCode == 200 {
                // Verification code verified successfully, navigate to the password change screen
                // Update your UI accordingly
                DispatchQueue.main.async {
                    isCodeVerificationActive = false
                    isPasswordChangeActive = true
                }
            } else {
                // Handle error cases
                print("Error: \(response.statusCode)")
                
                if let data = data {
                    do {
                        if let errorResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let errorMessage = errorResponse["error"] as? String {
                            // Error message received from the server
                            print("Error: \(errorMessage)")
                            // Update your UI to show the error message
                        } else {
                            // Generic error message
                            let errorString = String(data: data, encoding: .utf8) ?? "An error occurred"
                            print("Error: \(errorString)")
                            // Update your UI to show a generic error message
                        }
                    } catch {
                        print("Error parsing error response: \(error)")
                        // Update your UI to show a generic error message
                    }
                } else {
                    // No data received
                    print("Error: No data received")
                    // Update your UI to show a generic error message
                }
            }
        }
        
        task.resume()
    }




    
    func changePassword(newPassword: String) {
        let url = URL(string: "http://localhost:8800/api/auth/changepassword")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "email": email,
            "newPassword": newPassword
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("Error: No data or response received")
                return
            }
            
            if response.statusCode == 200 {
                // Password changed successfully
                // Navigate to login screen or perform any other action
                DispatchQueue.main.async {
                              showAlert = true
                    alertMessage = "Password changed successfully"
                          }
            } else {
                // Handle error cases
                print("Error: \(response.statusCode)")
                // Update your UI to show an error message
            }
        }
        
        task.resume()
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
