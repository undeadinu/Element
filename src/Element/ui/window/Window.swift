import Cocoa

class Window:NSWindow, NSApplicationDelegate, NSWindowDelegate/*,IElement*/ {
    lazy var view:NSView = {WindowView(self.frame.width,self.frame.height)}()/*Sets the mainview of the window*/
    override var canBecomeMain:Bool{return true}
    override var canBecomeKey:Bool{return true}/*If you want a titleless window to be able to become a key window, you need to create a subclass of NSWindow and override -canBecomeKeyWindow*/
    override var acceptsFirstResponder:Bool{return true}
    /**
     * NOTE: Remember to not set the width or height for the window in the css if you want the resizing working
     * NOTE: self.opaque = false/*use this value in conjunction with a transperant color and you can make the window transperant*/
     * NOTE: self.acceptsMouseMovedEvents = true/*<--new, could enable you to use the overide mouseMoved*/
     * TODO: Implement the max and min sizes into the constructor arguments
     * TODO: Implement x and y for the win on init (This is tricky to get right, carefull)
     */
    required init(_ width:CGFloat = 600,_ height:CGFloat = 400){/*required prefix in the init is so that instances can be created via factory design patterns*/
        let styleMask:NSWindow.StyleMask = [.titled, .resizable,.fullSizeContentView]/*represents the window attributes, this can also be set later*/
        let rect:NSRect = NSMakeRect(0, 0, width, height)
        super.init(contentRect: rect, styleMask:styleMask , backing: NSWindow.BackingStoreType.buffered, defer: false)//NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask|NSClosableWindowMask
        self.backgroundColor = .clear/*Sets the window background color*/
        self.makeKeyAndOrderFront(self)/*This moves the window to front and makes it key, should also be settable from within the win itself, test this*/
        self.hasShadow = true/*you have to set this to true if you want a shadow when using the borderlessmask setting*/
        /**/
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        //self.center()/*centers the window, this can also be done via WinModifier.align right after the init, carefull with self.center() as it overrides other alignment methods*/
        self.isReleasedWhenClosed = false/*<--This makes it possible to close and open the same window programtically, true for panels, false for unique docwin etc*/
        self.isMovableByWindowBackground = false/*This enables you do drag the window around via the background*/
        self.isMovable = false
        
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.delegate = self/*So that we can use this class as the Window controller aswell*/
        resolveSkin()
    }
    /**
     * Override this to add custom window resize code
     */
    func windowDidResize(_ notification:Notification) {
        //Swift.print("Window.windowDidResize")
        if let contentView = (self.contentView as? Element) {contentView.setSize(self.frame.size.width,self.frame.size.height)}
    }
    /**
     * We use the resolveSkin method since this is the common way to implement functionality in this framework
     */
    func resolveSkin(){
        _ = contentView
    }
    /**
     * I think this serves as a block for closing, i.e: prompt the user to save etc
     */
    func windowShouldClose(sender:AnyObject) -> Bool {
        //Swift.print("windowShouldClose")
        return true
    }
}
