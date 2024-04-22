import SwiftUI
import Alamofire

struct ContentView: View {
    @State var currencyList = [String]()
    @State var input = "100"
    @State var base = "USD"
    @FocusState private var inputIsFocused: Bool

    func makeRequest(showAll: Bool, currencies: [String] = ["USD", "GBP", "EUR"]) {
        let apiKey = "619a684ed5e9453190629531"
        let url = "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(base)?amount=\(input)"

        AF.request(url).responseDecodable(of: CurrencyData.self) { response in
            switch response.result {
            case .success(let currencyData):
                var tempList = [String]()
                for (key, value) in currencyData.conversion_rates {
                    let formattedValue = String(format: "%.2f", value)
                    let currencyString = "\(key) \(formattedValue)"
                    
                    if showAll || currencies.contains(key) {
                        tempList.append(currencyString)
                    }
                }
                tempList.sort()
                DispatchQueue.main.async {
                    currencyList = tempList
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack() {
            HStack {
                Text("Currencies")
                    .font(.system(size: 30))
                    .bold()
                
                Image(systemName: "eurosign.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
            }
            List {
                ForEach(currencyList, id: \.self) { currency in
                    Text(currency)
                }
            }
            VStack {
                Rectangle()
                    .frame(height: 8.0)
                    .foregroundColor(.blue)
                    .opacity(0.90)
                TextField("Enter an amount" ,text: $input)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .cornerRadius(20.0)
                    .padding()
                    .keyboardType(.decimalPad)
                    .focused($inputIsFocused)
                TextField("Enter a currency" ,text: $base)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .cornerRadius(20.0)
                    .padding()
                    .focused($inputIsFocused)
                Button("Convert!") {
                    makeRequest(showAll: true)
                    inputIsFocused = false
                }.padding()
            }
            
        }.onAppear() {
            makeRequest(showAll: true)
        }
    }
}

struct CurrencyData: Codable {
    var conversion_rates: [String: Double]
}


