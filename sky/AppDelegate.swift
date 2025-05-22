import UIKit
import CoreLocation

class AppDelegate: NSObject, UIApplicationDelegate {
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Check if the app was launched due to a location event
        if let launchOptions = launchOptions,
           launchOptions[UIApplication.LaunchOptionsKey.location] != nil {
            // App was launched from a location update
            print("App launched from location update")
            locationManager.startUpdatingLocation()
        }
        
        return true
    }
}

// In your main app file
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 