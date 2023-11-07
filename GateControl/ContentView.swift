//
//  ContentView.swift
//  GateControl
//
//  Created by Tatiana Zudina on 02.11.2023.
//

import SwiftUI
import SimpleToast

struct SimpleButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(maxWidth: 100, maxHeight: 100)
			.padding(50)
			.background(
				Group {
					if configuration.isPressed {
						Color(#colorLiteral(red: 0.7608050108, green: 0.8164883852, blue: 0.9259157777, alpha: 1))
						RoundedRectangle(cornerRadius: 16, style: .continuous)
							.foregroundColor(.white)
							.blur(radius: 4)
							.offset(x: 8, y: 8)
					} else {
						Color(#colorLiteral(red: 0.7608050108, green: 0.8164883852, blue: 0.9259157777, alpha: 1))
						RoundedRectangle(cornerRadius: 16, style: .continuous)
							.foregroundColor(.white)
							.blur(radius: 4)
							.offset(x: -8, y: -8)
						
						RoundedRectangle(cornerRadius: 16, style: .continuous)
							.fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9019607843, green: 0.9294117647, blue: 0.9882352941, alpha: 1)), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
							.padding(2)
							.blur(radius: 2)
					}
				}
			)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: Color(#colorLiteral(red: 0.7608050108, green: 0.8164883852, blue: 0.9259157777, alpha: 1)),radius: 16, x: 16, y: 16)
			.shadow(color: Color(.white),radius: 16, x: -16, y: -16)
	}
}


struct ContentView: View {
	
	@State private var showToast = false
	@State private var toastText = ""
	private var errorColor = Color(#colorLiteral(red: 0.8554748893, green: 0.9081590772, blue: 0.8240712285, alpha: 1))
	private var successColor = Color(#colorLiteral(red: 0.8301611543, green: 0.1263696253, blue: 0.2860267758, alpha: 0.865428394))
	@State private var isError = false
	
	
	
	
	private let toastOptions = SimpleToastOptions(
		alignment: .top,
		hideAfter: 4,
		backdropColor: Color.black.opacity(0.2),
		animation: .default,
		modifierType: .slide
	)
	
	
	func openGate() {
		
		guard let url = URL(string: "http://gate.hingai.keenetic.pro/led2on") else { fatalError("Missing URL") }
		
		let urlRequest = URLRequest(url: url)
		
		
		let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
			if let error = error {
				toastText = "Error: \(error.localizedDescription)"
				isError = true
				showToast.toggle()
				return
			}
			
			guard let response = response as? HTTPURLResponse else { return }
			
			if response.statusCode == 200 {
				guard let data = data else { return }
				DispatchQueue.main.async {
					do {
						toastText = "The Gate is open"
						isError = true
						showToast.toggle()
					}
				}
			}
			else {
				toastText = "Error: \(response.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))"
				isError = false
				showToast.toggle()
			}
		}
		dataTask.resume()
	}
	
	var body: some View {
		
		VStack(spacing: 40 ) {
			Text("Home Gate Control").fontWeight(.ultraLight).multilineTextAlignment(.center).kerning(3).font(.custom("Copperplate", size: 30)).padding(.bottom, 130)
				.frame(maxWidth: .infinity, maxHeight: 100)
			Button(action: {
				openGate()
			}, label: {
				Image("barrier").renderingMode(.template)
					.resizable()
					.scaledToFill()
					.frame(width: 70, height: 70, alignment: .center)
			})
			.buttonStyle(SimpleButtonStyle())
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color(#colorLiteral(red: 0.7687062735, green: 0.7793403745, blue: 1, alpha: 0.5)))
		
		.simpleToast(isPresented: $showToast, options: toastOptions) {
			HStack {
				//				Image(systemName: "door.garage.closed")
				Text(toastText).bold()
			}
			.padding(40)
			.background(isError ? errorColor : successColor)
			.foregroundColor(Color.black)
			.cornerRadius(14)
		}
	}
	
}

#Preview {
	ContentView()
}
