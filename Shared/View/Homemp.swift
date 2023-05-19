//
//  Home.swift
//  MapRoutes (iOS)
//
//  Created by Balaji on 03/01/21.
//

import SwiftUI
import CoreLocation

struct Homemp: View {
    
    @StateObject var mapData = MapViewModel()
    // Location Manager....
    @State var locationManager = CLLocationManager()
    @State var offset : CGFloat = 0
    var body: some View {
        
        ZStack{
            GeometryReader{reader in
            
                VStack{
                    
                    BottomSheet(offset: $offset, value: (-reader.frame(in: .global).height + 150))
                        .offset(y: reader.frame(in: .global).height - 140)
                    // adding gesture....
                        .offset(y: offset)
                        .gesture(DragGesture().onChanged({ (value) in
                            
                            withAnimation{
                                
                                // checking the direction of scroll....
                                
                                // scrolling upWards....
                                // using startLocation bcz translation will change when we drag up and down....
                                
                                if value.startLocation.y > reader.frame(in: .global).midX{
                                    
                                    if value.translation.height < 0 && offset > (-reader.frame(in: .global).height + 150){
                                        
                                        offset = value.translation.height
                                    }
                                }
                                
                                if value.startLocation.y < reader.frame(in: .global).midX{
 
                                    if value.translation.height > 0 && offset < 0{
                                        
                                        offset = (-reader.frame(in: .global).height + 150) + value.translation.height
                                    }
                                }
                            }
                            
                        }).onEnded({ (value) in
                            
                            withAnimation{
                                
                                // checking and pulling up the screen...
                                
                                if value.startLocation.y > reader.frame(in: .global).midX{
                                    
                                    if -value.translation.height > reader.frame(in: .global).midX{
                                        
                                        offset = (-reader.frame(in: .global).height + 150)
                                        
                                        return
                                    }
                                    
                                    offset = 0
                                }
                                
                                if value.startLocation.y < reader.frame(in: .global).midX{
                                    
                                    if value.translation.height < reader.frame(in: .global).midX{
                                        
                                        offset = (-reader.frame(in: .global).height + 150)
                                        
                                        return
                                    }
                                    
                                    offset = 0
                                }
                            }
                        }))
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            // MapView...
            MapView()
                // using it as environment object so that it can be used ints subViews....
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                VStack(spacing: 0){
                    HStack{
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $mapData.searchTxt)
                            .colorScheme(.light)
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal)
                    .background(Color.white)
                    
                    // Displaying Results...
                    
                    if !mapData.places.isEmpty && mapData.searchTxt != ""{
                        
                        ScrollView{
                            
                            VStack(spacing: 15){
                                
                                ForEach(mapData.places){place in
                                    
                                    Text(place.placemark.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .padding(.leading)
                                        .onTapGesture{
                                            
                                            mapData.selectPlace(place: place)
                                        }
                                    
                                    Divider()
                                }
                            }
                            .padding(.top)
                        }
                        .background(Color.white)
                    }
                    
                }
                .padding()
                
                Spacer()
                
                VStack{
                    
                    Button(action: mapData.focusLocation, label: {
                        
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                    
                    Button(action: mapData.updateMapType, label: {
                        
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
        }
        .onAppear(perform: {
            
            // Setting Delegate...
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        })
        // Permission Denied Alert...
        .alert(isPresented: $mapData.permissionDenied, content: {
            
            Alert(title: Text("Permission Denied"), message: Text("Please Enable Permission In App Settings"), dismissButton: .default(Text("Goto Settings"), action: {
                
                // Redireting User To Settings...
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onChange(of: mapData.searchTxt, perform: { value in
            
            // Searching Places...
            
            // You can use your own delay time to avoid Continous Search Request...
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                
                if value == mapData.searchTxt{
                    
                    // Search...
                    self.mapData.searchQuery()
                }
            }
        })
    }
}

struct Homemp_Previews: PreviewProvider {
    static var previews: some View {
        Homemp()
    }
}
