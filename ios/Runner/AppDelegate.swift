import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var blurView: UIVisualEffectView?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up screenshot protection method channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let screenshotChannel = FlutterMethodChannel(
        name: "com.example.untitled2/screenshot_protection",
        binaryMessenger: controller.binaryMessenger
      )
      
      screenshotChannel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "enableScreenshotProtection":
          self?.enableScreenshotProtection()
          result(true)
        case "disableScreenshotProtection":
          self?.disableScreenshotProtection()
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    // Enable screenshot protection by default
    enableScreenshotProtection()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func enableScreenshotProtection() {
    // Prevent screenshots and screen recordings
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleWillResignActive),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    // Prevent screen capture/recording
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
  }
  
  private func disableScreenshotProtection() {
    NotificationCenter.default.removeObserver(self)
    removeBlurView()
  }
  
  @objc private func handleWillResignActive() {
    // Add blur view to hide content when app goes to background or during app switching
    addBlurView()
  }
  
  @objc private func handleDidBecomeActive() {
    // Remove blur view when app becomes active
    removeBlurView()
  }
  
  @objc private func screenCaptureDidChange() {
    // Check if screen is being captured/recorded
    if UIScreen.main.isCaptured {
      // Hide the app content or show warning
      addBlurView()
    } else {
      removeBlurView()
    }
  }
  
  private func addBlurView() {
    guard blurView == nil else { return }
    
    let blurEffect = UIBlurEffect(style: .dark)
    let effectView = UIVisualEffectView(effect: blurEffect)
    blurView = effectView
    
    if let window = window {
      effectView.frame = window.bounds
      effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      // Add a security icon or message
      let securityLabel = UILabel()
      securityLabel.text = "🔒 Content Protected"
      securityLabel.textColor = .white
      securityLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
      securityLabel.textAlignment = .center
      securityLabel.translatesAutoresizingMaskIntoConstraints = false
      
      effectView.contentView.addSubview(securityLabel)
      
      NSLayoutConstraint.activate([
        securityLabel.centerXAnchor.constraint(equalTo: effectView.centerXAnchor),
        securityLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor)
      ])
      
      window.addSubview(effectView)
    }
  }
  
  private func removeBlurView() {
    blurView?.removeFromSuperview()
    blurView = nil
  }
}
