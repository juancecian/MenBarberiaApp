import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
  
  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    // Get screen dimensions
    guard let screen = screen ?? NSScreen.main else {
      return super.constrainFrameRect(frameRect, to: screen)
    }
    
    let screenFrame = screen.visibleFrame
    
    // Calculate 80% of screen size as minimum
    let minWidth = screenFrame.width * 0.8
    let minHeight = screenFrame.height * 0.8
    
    // Ensure the frame meets minimum requirements
    var constrainedFrame = frameRect
    
    if constrainedFrame.width < minWidth {
      constrainedFrame.size.width = minWidth
    }
    
    if constrainedFrame.height < minHeight {
      constrainedFrame.size.height = minHeight
    }
    
    // Ensure window fits on screen
    if constrainedFrame.width > screenFrame.width {
      constrainedFrame.size.width = screenFrame.width
    }
    
    if constrainedFrame.height > screenFrame.height {
      constrainedFrame.size.height = screenFrame.height
    }
    
    // Center if necessary
    if constrainedFrame.origin.x + constrainedFrame.width > screenFrame.maxX {
      constrainedFrame.origin.x = screenFrame.maxX - constrainedFrame.width
    }
    
    if constrainedFrame.origin.y + constrainedFrame.height > screenFrame.maxY {
      constrainedFrame.origin.y = screenFrame.maxY - constrainedFrame.height
    }
    
    return super.constrainFrameRect(constrainedFrame, to: screen)
  }
}
