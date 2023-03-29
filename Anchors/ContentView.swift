//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: {
                    Sample0()
                }, label: {
                    Text("Sample 0")
                })
                NavigationLink(destination: {
                    Sample1()
                }, label: {
                    Text("Sample 1")
                })
                NavigationLink(destination: {
                    Sample2()
                }, label: {
                    Text("Sample 2")
                })
                NavigationLink(destination: {
                    Sample3()
                }, label: {
                    Text("Sample 3")
                })
            }.listStyle(.sidebar)
            Text("Select a sample")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
