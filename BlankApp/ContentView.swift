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

func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
    true
    #else
    false
    #endif
}

struct ContentView: View {
    /* Some costants */
    let isLoaded = dlopen("frida-agent.dylib", RTLD_NOW) != nil
    let success = createEmptyTextFile(atPath: "/var/mobile/file.txt")
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "UNDEFINED"
    let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    let isiOS15 = (UIDevice.current.systemVersion as NSString).floatValue >= 15
    
    var body: some View {
        VStack {
            VStack {
                Text("AnForA").underline()
                    .font(thinFont)
                Text("for iOS").font(.system(size: 20, design: .monospaced))
                Text("(Version: " + appVersion + ", Build: " + buildVersion + ")")
                    .font(.system(size: 13))
                    .padding([.bottom], 20)
                VStack() {
                    ScrollView() {
                        VStack(alignment: .leading, spacing: 10) {
                            Group {
                                Text("Current " + UIDevice.current.systemName + " version: ").bold() + Text(UIDevice.current.systemVersion)
                                Divider().frame(height: 1).overlay(Color.orange.opacity(0.5))
                                Text("Is ").bold() + Text("frida-agent.dylib").font(.system(.body, design: .monospaced)) + Text(" loaded? ").bold() + Text(String(isLoaded).uppercased()).bold().foregroundColor(isLoaded ? .green : .red)
                                Divider().frame(height: 1).overlay(Color.orange.opacity(0.5))
                                Text("Documents").font(.system(.body, design: .monospaced)) + Text(" folder in my sandbox directory: ").bold() + Text(String(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString))
                                Divider().frame(height: 1).overlay(Color.orange.opacity(0.5))
                                Text("Can I write files outside my own sandbox directory? ").bold() + Text(String(success).uppercased()).bold().foregroundColor(success ? .green : .red)
                                Divider().frame(height: 1).overlay(Color.orange.opacity(0.5))
                            }
                            if let bundleID = Bundle.main.bundleIdentifier {
                                Text("Bundle ID: ").bold() + Text(bundleID)
                            } else {
                                Text("Bundle ID: ").bold() + Text("Bundle ID not found!").foregroundColor(.red)
                            }
                            Divider().frame(height: 1).overlay(Color.orange.opacity(0.5))
                            if let executablePath = Bundle.main.executablePath {
                                Text("Executable path: ").bold() + Text(executablePath)
                            } else {
                                Text("Executable path: ").bold() + Text("Executable path not found!").foregroundColor(.red)
                            }
                        }
                    }.frame(
                        width: 375,
                        height: (isSimulator()) ? 500 : 400 // TODO: it can be improved
                    )
                }.background(
                    Image("Background").resizable().scaledToFill().blur(radius: 15)
                )
            }.padding([.bottom], 20)
            Text("This " + UIDevice.current.systemName) + Text((isiOS15) ? " IS SUPPORTED" : " IS NOT SUPPORTED").bold().foregroundColor((isiOS15) ? .green : .red)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
