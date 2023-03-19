import SwiftUI

let thinUIFont = UIFont(name: "HelveticaNeue-Thin", size: 64)!
let thinFont = Font(thinUIFont)

/**
 Creates an empty text file at the specified path.
 
 - Parameter path: The path where the text file should be created. This path must be outside of the app's sandbox, or the function will fail.
 - Returns: `true` if the text file was created successfully, or `false` if an error occurred.
 */
func createEmptyTextFile(atPath path: String) -> Bool {
    // Convert the path to a URL
    let url = URL(fileURLWithPath: path)
    
    // Attempt to create an empty text file at the URL
    do {
        try "".write(to: url, atomically: true, encoding: .utf8)
        return true // Return true if the file was created successfully
    } catch {
        print("Error creating file: \(error.localizedDescription)")
        return false // Return false if an error occurred
    }
}

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
                    let forbiddenPath = "/var/mobile/file.txt"
                    let success = createEmptyTextFile(atPath: forbiddenPath)
                    Text("Out of the box? ").bold() + Text(String(success).uppercased()).bold().foregroundColor(success ? .green : .red)
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
