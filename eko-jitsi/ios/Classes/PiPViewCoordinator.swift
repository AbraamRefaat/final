import UIKit
import JitsiMeetSDK

class PiPViewCoordinator {
    private var jitsiMeetView: JitsiMeetView
    private var parentView: UIView?
    
    init(withView view: JitsiMeetView) {
        self.jitsiMeetView = view
    }
    
    func configureAsStickyView(withParentView parentView: UIView) {
        self.parentView = parentView
    }
    
    func show() {
        guard let parentView = parentView else { return }
        
        parentView.addSubview(jitsiMeetView)
        jitsiMeetView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            jitsiMeetView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
            jitsiMeetView.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor),
            jitsiMeetView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            jitsiMeetView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.3) {
            self.jitsiMeetView.alpha = 1.0
        }
    }
    
    func hide(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.jitsiMeetView.alpha = 0.0
        }) { finished in
            self.jitsiMeetView.removeFromSuperview()
            completion(finished)
        }
    }
    
    func resetBounds(bounds: CGRect) {
        jitsiMeetView.frame = bounds
    }
    
    func enterPictureInPicture() {
        // Implement picture-in-picture logic here if needed
        // For now, we'll just keep it as a regular view
        print("Picture in Picture mode requested")
    }
}
