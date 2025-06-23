import SwiftUI

let fundoFinances = LinearGradient(
    colors: [Color(hex: "#C789D2"), Color(hex: "#EFEFEF")],
    startPoint: .top,
    endPoint: UnitPoint(x: 0.5, y: 0.2))
    

struct FinancesView: View {
    @State private var teste = 0
    var body: some View {
        NavigationView {
            ZStack {
                    fundoFinances
                        .ignoresSafeArea()
                    VStack{
                        Picker("teste", selection: $teste){
                            Text("Pendentes").tag(0)
                            Text("Paga por todos").tag(1)
                        }
                        .pickerStyle(.segmented)
                        }
                }
            .navigationTitle("Despesas")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{
                        print("oi")
                    }label:{
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }

    }
}

struct teste_preview: PreviewProvider{
    
    static var previews: some View{
        FinancesView()
    }
}
