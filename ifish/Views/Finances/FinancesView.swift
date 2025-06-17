import SwiftUI

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2))
    

struct FinancesView: View {
    
    var body: some View {
        NavigationView {
            ZStack{
                fundoFinances.ignoresSafeArea()
                Text("Teste")
            }
        }
        .navigationTitle("Despesas")

}
}
