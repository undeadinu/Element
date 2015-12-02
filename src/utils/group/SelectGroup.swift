import Foundation
/**
 * EXAMPLE:
 * var radioButtonGroup:RadioButtonGroup = RadioButtonGroup([rb1,rb2, rb3]);
 * radioButtonGroup.addEventListener(Event.CHANGE, onChange);
 * function onChange(event:Event):void { trace("event"+RadioButtonGroup(event.currentTarget).checkedRadioButton);}
 */
class SelectGroup {
    private var selectables:Array<ISelectable> = [];
    private var selected:ISelectable?;
    init(selectables:Array<ISelectable>, selected:ISelectable? = nil){
        addSelectables(selectables);
        self.selected = selected
    }
    func addSelectables(selectables:Array<ISelectable>){
        for item : ISelectable in selectables {addSelectable(item)}
    }
    /**
     * @Note useWeakReference is set to true so that we dont have to remove the event if the selectable is removed from the SelectGroup or view
     */
    func addSelectable(selectable:ISelectable) {
        let anyObj:AnyObject = selectable
        NSNotificationCenter.defaultCenter().addObserver(anyObj, selector: "onSelect:", name: SelectEvent.select, object: anyObj)
        NSNotificationCenter.defaultCenter().addObserver(anyObj, selector: "onSelect:", name: SelectEvent.deSelect, object: anyObj)
        selectables.append(selectable);
    }
    func onSelect(sender: AnyObject) {// :TODO: make this as protected since you may want to impose different functionaly when clicked, like multi select etc
        NSNotificationCenter.defaultCenter().postNotificationName(SelectGroupEvent.select, object:self)/*bubbles:true because i.e: radioBulet may be added to RadioButton and radioButton needs to dispatch Select event if the SelectGroup is to work*/
        selected = (sender as! NSNotification).object as? ISelectable
        SelectModifier.unSelectAllExcept(selected!, selectables);
        NSNotificationCenter.defaultCenter().postNotificationName(SelectGroupEvent.change, object:self)
    }
}