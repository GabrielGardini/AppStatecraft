import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            AppStartView()
                .background(Color("BackgroundColor").ignoresSafeArea())
        }
    }
}
