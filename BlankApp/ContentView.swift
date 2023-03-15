import SwiftUI

let thinUIFont = UIFont(name: "HelveticaNeue-Thin", size: 64)!
let thinFont = Font(thinUIFont)

struct ContentView: View {
    var body: some View {
        VStack {
            VStack {
                Text("AnForA").underline()
                    .font(thinFont)
                Text("for iOS").font(.system(size: 20, design: .monospaced))
                    .padding([.bottom], 20)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current model: ").bold() + Text(UIDevice.current.name)
                    Text("Current " + UIDevice.current.systemName + " version: ").bold() + Text(UIDevice.current.systemVersion)
                    let isLoaded = dlopen("frida-agent.dylib", RTLD_NOW) != nil
                    Text("Is ").bold() + Text("frida-agent.dylib").font(.system(.body, design: .monospaced)) + Text(" loaded? ") + Text(String(isLoaded).uppercased()).bold().foregroundColor(isLoaded ? .green : .red)
                    
                }.padding([.bottom], 80)
            }.background(
                Image("Background").resizable().scaledToFill().blur(radius: 8)
            )
            let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue
            if (floatVersion >= 15) {
                (Text("This " + UIDevice.current.systemName) + Text(" IS SUPPORTED").bold().foregroundColor(.green))
            } else {
                Text("This " + UIDevice.current.systemName) + Text(" IS NOT SUPPORTED").bold().foregroundColor(.red)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
