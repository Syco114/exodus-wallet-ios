import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WalletView()
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Wallet")
                }
                .tag(0)
            
            ActivityView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Activity")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .environmentObject(walletManager)
        .accentColor(.purple)
    }
}

// MARK: - Wallet Manager
class WalletManager: ObservableObject {
    @Published var isDarkMode = true
    @Published var btcBalance: Double = 0.01234567
    @Published var ethBalance: Double = 1.23456789
    
    let btcAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
    let ethAddress = "0x742d35Cc6834C0532925a3b8d0a1bc4a2b5C7e8A"
    
    var btcValue: Double {
        btcBalance * 45000 // Mock BTC price
    }
    
    var ethValue: Double {
        ethBalance * 2800 // Mock ETH price
    }
    
    var totalValue: Double {
        btcValue + ethValue
    }
}

// MARK: - Wallet View
struct WalletView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var showingEditBalance = false
    @State private var selectedCoin: CoinType?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.purple.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Balance")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("$\(walletManager.totalValue, specifier: "%.2f")")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingEditBalance = true
                            }) {
                                Image(systemName: "pencil.circle")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack(spacing: 15) {
                            ActionButton(title: "Send", icon: "arrow.up", color: .red)
                            ActionButton(title: "Receive", icon: "arrow.down", color: .green)
                            ActionButton(title: "Buy", icon: "plus", color: .blue)
                            ActionButton(title: "Swap", icon: "arrow.2.squarepath", color: .orange)
                        }
                        .padding(.horizontal)
                        
                        // Coins List
                        VStack(spacing: 15) {
                            CoinRow(
                                coinType: .bitcoin,
                                balance: walletManager.btcBalance,
                                value: walletManager.btcValue
                            )
                            .onTapGesture {
                                selectedCoin = .bitcoin
                            }
                            
                            CoinRow(
                                coinType: .ethereum,
                                balance: walletManager.ethBalance,
                                value: walletManager.ethValue
                            )
                            .onTapGesture {
                                selectedCoin = .ethereum
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditBalance) {
            EditBalanceView()
        }
        .sheet(item: $selectedCoin) { coin in
            CoinDetailView(coinType: coin)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Non-functional button
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Coin Types
enum CoinType: String, CaseIterable, Identifiable {
    case bitcoin = "BTC"
    case ethereum = "ETH"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        }
    }
    
    var icon: String {
        switch self {
        case .bitcoin: return "bitcoinsign.circle.fill"
        case .ethereum: return "e.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bitcoin: return .orange
        case .ethereum: return .blue
        }
    }
}

// MARK: - Coin Row
struct CoinRow: View {
    let coinType: CoinType
    let balance: Double
    let value: Double
    
    var body: some View {
        HStack(spacing: 15) {
            // Coin Icon
            Image(systemName: coinType.icon)
                .font(.title)
                .foregroundColor(coinType.color)
                .frame(width: 40)
            
            // Coin Info
            VStack(alignment: .leading, spacing: 4) {
                Text(coinType.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(balance, specifier: "%.8f") \(coinType.rawValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Value
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(value, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("+2.4%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Edit Balance View
struct EditBalanceView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode
    @State private var btcText = ""
    @State private var ethText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Edit Balances")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        // BTC Balance
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bitcoin Balance")
                                .foregroundColor(.gray)
                            
                            TextField("0.00000000", text: $btcText)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        
                        // ETH Balance
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ethereum Balance")
                                .foregroundColor(.gray)
                            
                            TextField("0.000000000", text: $ethText)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    Button("Update Balances") {
                        if let btc = Double(btcText) {
                            walletManager.btcBalance = btc
                        }
                        if let eth = Double(ethText) {
                            walletManager.ethBalance = eth
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .onAppear {
            btcText = String(walletManager.btcBalance)
            ethText = String(walletManager.ethBalance)
        }
    }
}

// MARK: - Coin Detail View
struct CoinDetailView: View {
    @EnvironmentObject var walletManager: WalletManager
    let coinType: CoinType
    @Environment(\.presentationMode) var presentationMode
    
    var balance: Double {
        switch coinType {
        case .bitcoin: return walletManager.btcBalance
        case .ethereum: return walletManager.ethBalance
        }
    }
    
    var address: String {
        switch coinType {
        case .bitcoin: return walletManager.btcAddress
        case .ethereum: return walletManager.ethAddress
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: coinType.icon)
                                .font(.system(size: 60))
                                .foregroundColor(coinType.color)
                            
                            Text(coinType.name)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("\(balance, specifier: "%.8f") \(coinType.rawValue)")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        
                        // QR Code
                        VStack(spacing: 15) {
                            Text("Receive Address")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if let qrImage = generateQRCode(from: address) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            Text(address)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 15) {
                            Button("Copy Address") {
                                UIPasteboard.general.string = address
                            }
                            .buttonStyle(SecondaryButtonStyle())
                            
                            Button("Send \(coinType.rawValue)") {
                                // Non-functional
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - Activity View
struct ActivityView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Transaction History")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(0..<10) { index in
                                TransactionRow(
                                    type: index % 2 == 0 ? "Received" : "Sent",
                                    coin: index % 3 == 0 ? "BTC" : "ETH",
                                    amount: Double.random(in: 0.001...1.0),
                                    date: Date().addingTimeInterval(-Double(index * 86400))
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let type: String
    let coin: String
    let amount: Double
    let date: Date
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: type == "Received" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(type == "Received" ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(formatter.string(from: date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(type == "Received" ? "+" : "-")\(amount, specifier: "%.6f") \(coin)")
                    .font(.headline)
                    .foregroundColor(type == "Received" ? .green : .red)
                
                Text("Confirmed")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var walletManager: WalletManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    Section {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.purple)
                            Text("Dark Mode")
                            Spacer()
                            Toggle("", isOn: $walletManager.isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                        
                        SettingsRow(icon: "key.fill", title: "Security", color: .orange)
                        SettingsRow(icon: "network", title: "Network", color: .blue)
                        SettingsRow(icon: "bell.fill", title: "Notifications", color: .green)
                        SettingsRow(icon: "questionmark.circle.fill", title: "Support", color: .cyan)
                    }
                    .foregroundColor(.white)
                    
                    Section {
                        SettingsRow(icon: "info.circle.fill", title: "About", color: .gray)
                        SettingsRow(icon: "doc.text.fill", title: "Terms of Service", color: .gray)
                        SettingsRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .gray)
                    }
                    .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Non-functional
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
    }
}

// MARK: - Custom Styles
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .stroke(Color.purple.opacity(0.5), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.purple)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
