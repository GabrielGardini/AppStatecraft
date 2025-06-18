import SwiftUI

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2))
    

struct FinancesView: View {
    var body: some View {
            ZStack {
                fundoFinances
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Despesas")
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                        Button(action: {
                            print("botao")
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .contentShape(Rectangle())
                        .zIndex(1)                    }
                    .padding([.top, .horizontal], 24)
                    
                    Spacer()
                    
                    Text("teste")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true) // Opcional: esconde a barra do NavigationView
            .navigationBarTitleDisplayMode(.inline)
        }
    }

