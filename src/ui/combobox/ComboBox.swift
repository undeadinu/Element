import Cocoa
/** 
 * @Note for multiSelect option make MultiCheckComboBox.as aand CheckComboBox?
 * @Note: to get the height while the list is pulled down: comboBox.height * comboBox.maxShowingItems
 * // :TODO: add isScrollBarVisible as an argument at the end, butbefore, parent and name
 * // :TODO: add a way to set the init selected list item, and have this update the header, (if headerText != null that is)
 * // :TODO: add height as an argument to the constructor
 * // :TODO: find a way to add a mask that can have rounded corners, if a TextButton has a square fill then it overlaps outside the combobox
 * //closeOnClick
 * //defaultText
 * TODO: Upgrade the ComboBox to support popping open a window that hovers above the origin window. It needs to align it self to the screen correctly etc
 */
class ComboBox:Element{
    var headerButton:TextButton?
    var itemHeight:CGFloat// :TODO: this should be set in the css?
    var dataProvider:DataProvider?
    var list:SliderList?
    var isOpen:Bool
    var depth:Int?/*used to store the temp sprite depth so the popover can hover over other instance siblings*/
    var initSelected:Int
    var popOver:PopWin?
    static var popupWindow:PopupWindow?
	init(_ width:CGFloat = NaN, _ height:CGFloat = NaN, _ itemHeight:CGFloat = NaN ,_ dataProvider:DataProvider? = nil, _ isOpen:Bool = false, _ initSelected:Int = 0, _ parent:IElement? = nil, _ id:String? = nil){
		self.itemHeight = itemHeight
		self.dataProvider = dataProvider
		self.isOpen = isOpen
		self.initSelected = initSelected
		super.init(width,height,parent,id)
	}
	override func resolveSkin(){
		super.resolveSkin()
		headerButton = addSubView(TextButton(width, itemHeight,"", self))// :TODO: - _itemHeight should be something else
        list = /*addSubView*/(SliderList(width, height, itemHeight, dataProvider, self))
        ListModifier.selectAt(list!, initSelected)
        headerButton!.setTextValue(ListParser.selectedTitle(list!))
        setOpen(isOpen)
	}
    func onPopUpWinEvent(event:Event){
        Swift.print("onPopUpWinEvent")
    }
	func onHeaderMouseDown(event:ButtonEvent) {
        Swift.print("onHeaderMouseDown")
        ComboBox.popupWindow = PopupWindow(100,100)
        
        (ComboBox.popupWindow!.contentView as! WindowView).event = self.onPopUpWinEvent//add event handler
        
        
        //popOver = PopWin()
        //popOver?.showRelativeToRect(NSZeroRect, ofView: self, preferredEdge: NSRectEdge.MaxX)
        
		setOpen(!isOpen)
        super.onEvent(ComboBoxEvent(ComboBoxEvent.headerClick,ListParser.selectedIndex(list!),self))/*send this event*/
	}
	func onGlobalClick() {//On clicks outside combobox, close the combobox
		//if (!hitTestPoint(x, y)) {//you sort of check if the mouse-click didnt happen within the bounds of the comboBox
			//setOpen(false);
			//remove the globalListener here
		//}
	}
	/**
	 * the select event should be fired only onReleaseInside not as it is now onPress
	 */
	func onListSelect(event:ListEvent) {
		let text:String = ListParser.selectedTitle(list!)
		headerButton!.setTextValue(text)
		setOpen(false)
	}
	override func onEvent(event:Event){
        
		if(event.type == ListEvent.select && event.origin === list){onListSelect(event as! ListEvent)}
		if(event.type == ButtonEvent.down && event.origin === headerButton){onHeaderMouseDown(event as! ButtonEvent)}
	}
	func setOpen(isOpen:Bool) {
        Swift.print("setOpen")
        
        
		/*
        if(isOpen){
			depth = (getParent(true) as! NSView).getSubViewIndex(self)
			DepthModifier.toFront(this,getParent(true))// :TODO: will this work in Element 2 framework? it does for now, and use parennt.setChildIndex this method is old
		}else if(self.window != null) (getParent(true) as! NSView).setSubViewIndex(self, depth)
		self.isOpen = isOpen// :TODO: here is the problem since if you resize the skin is updated and visible is reset, also mask in list should be an element with float and clear set to none, do a test and see if you can overlap 2 elements
		ElementModifier.hide(list, isOpen)
		if(isOpen && window != nil && !window.hasEventListener(MouseEvent.MOUSE_DOWN)) {}//add globalListener
		if(!isOpen && window != nil && widn.hasEventListener(MouseEvent.MOUSE_DOWN)) {}//remove globalListener // :TODO: fix this mess
        */
	}
	override func setSize(width:CGFloat, _ height:CGFloat)  {
		super.setSize(width, height)
		list!.setSize(width, StylePropertyParser.height(list!.skin!)!)/*temp solution*/
		headerButton!.setSize(width, StylePropertyParser.height(headerButton!.skin!)!)/*temp solution*/
	}
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}

class PopWin:NSPopover, NSPopoverDelegate{
    var view:WindowView?
    var viewController:PopViewController?
    override init() {
        Swift.print("PopWin")
        super.init()
        self.behavior = .Semitransient
        
        self.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)!
        self.contentSize = NSSize(100,100)
        view = PopView(100,100,nil,"special")
        viewController = PopViewController(view!)
        self.contentViewController = viewController
        self.delegate = self
        //self.positioningRect = CGRect(0,0,100,100)

        
        
    }
    func popoverWillShow(notification: NSNotification) {
        Swift.print("popoverWillShow")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class PopView:WindowView{
    override func resolveSkin() {
        Swift.print("resolveSkin")
        StyleManager.addStyle("Window#special{fill:red;}")
        super.resolveSkin()
    }
}
class PopViewController:NSViewController{
    init(_ view:NSView){
        super.init(nibName: nil, bundle: nil)!
        self.view = view
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class PopupWindow:Window{
    required init(_ width: CGFloat, _ height: CGFloat) {
        super.init(width,height)
        WinModifier.align(self, Alignment.centerCenter, Alignment.centerCenter)
    }
    override func resolveSkin() {
        super.resolveSkin()
        self.contentView = PopupView(frame.width,frame.height,nil,"special")/*Sets the mainview of the window*/
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
/**
 * NOTE: the difference between local and global monitors is that local takes care of events that happen inside an app window, and the global handle events that also is detected outside an app window.
 */
class PopupView:WindowView{
    var leftMouseDownEventListener:AnyObject?
    override func resolveSkin() {
        Swift.print("PopupView.resolveSkin")
        StyleManager.addStyle("Window#special{fill:red;}")
        super.resolveSkin()
        if(leftMouseDownEventListener == nil) {leftMouseDownEventListener = NSEvent.addGlobalMonitorForEventsMatchingMask([.LeftMouseDownMask], handler:self.onMouseDown ) }//we add a global mouse move event listener
        else {fatalError("This shouldn't be possible, if it throws this error then you need to remove he eventListener before you add it")}
    }
    
    func onMouseDown(event:NSEvent) {
        Swift.print("PopupView.onMouseDown()")
        super.onEvent(Event(Event.update,self))
        if(leftMouseDownEventListener != nil){
            NSEvent.removeMonitor(leftMouseDownEventListener!)
            leftMouseDownEventListener = nil
        }
        //TODO: set the event to it self again here
        self.window!.close()
        //return event
    }
}

//IMPORTANT: try to open the popover window when the origin window is in fullscreen mode (works)
//Figure out how to listen to mouseEvents outside and inside NSWindow

//1. on click outside of the popup window needs to be recorded (done)
//2. click a button in popupWin sends an event and then closes it self (done)
//3. the popupWindow needs to be stored somewhere, maybe in a static variable or somewhere else in the Element framework (done)
//4. Make an universal alignment method for aligning windows, you can probably use the regular Align method here with a zeroSize and CGPoint and TopCenter as the alignment type
//5. try to animate the popup effect
//6. the popupwin must have an init with size and position, 
//7. populate the window with a List/SliderList
//8. hock up the List event
//9. create the ComboBoxPopUpWindow
//10. you need a method that checks avilable space for the popup to be shown in (mesure screen vs origin-pos vs popup-size) <--do some doodeling etc




