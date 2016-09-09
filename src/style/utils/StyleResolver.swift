import Foundation

class StyleResolver{
    static var recently:Array<(style:IStyle,address:String)> = []
    /**
     *
     */
    static func style(element:IElement)->IStyle{
        let elementAddress = ElementParser.stackString(element)
        var index = -1
        for var i = 0; i < recently.count; ++i{
            let item = recently[i]
            if(item.address == elementAddress) {
                index = i
                break;//terminate Loop
            }
        }
        if(index != -1){//already exists in cache
            ArrayModifier.move(&recently, index, 0)//move to front
            return recently[index].style
        }else{//does not exist in cache
            if(recently.count > 9){recently.popLast()}
            recently.unshift((style,elementAddress))//add to front
        }

        
        return resolveStyle(element)
    }
    /**
     * Returns a style comprised of all the styleProperties element inherit from
     * NOTE: creates a list with styles in the styleManger the styles with highest priority goes to the top, then each consequtive style in this priority list is merged into the first one (if a styleProperty exists it is not overriden, all others are added), styles in the stylemanager that has nothing to do with the current cascade are not included in the priorityList
     * // :TODO: should only inherit when property is marked inherit or from * universal selectors!?!?
     */
    static func resolveStyle(element:IElement)->IStyle{
        let querrySelectors:Array<ISelector> = ElementParser.selectors(element)/*Array instance comprised of Selector instances for each (element,classId,id and state) in the element*/
        var weightedStyles:Array<WeightedStyle> = []
        for style : IStyle in StyleManager.styles {/*This loop disregards styles that don't apply to the element Selectors*/
            if(style.selectors.count > querrySelectors.count) {continue;}/*if there are more selectors in style.selectors than in cascade the final styleWeight.weight is 0 and there for it is not included in the weightedStyles array*/
            //Swift.print("style: " + style.name)
            let selectorWeights:Array<SelectorWeight>? = SelectorParser.selectorWeights(style,querrySelectors)
            if(selectorWeights != nil) {weightedStyles.append(WeightedStyle(style, StyleWeight(selectorWeights!)))}
        }
        //Swift.print("weightedStyles: " + weightedStyles.count)
        if(weightedStyles.count > 1) {
            weightedStyles = ArrayParser.conditionSort(weightedStyles, WeightedStyleAsserter.priority)/*Sorts each weightedStyle by its weight, the styles with most specificity has a lower index*/
        }
        let styleName:String = SelectorParser.string(querrySelectors)/*returns the absolute selecter address of the element*/
        var finalStyle:IStyle = StyleManager.getStyle(styleName) ?? Style(styleName,querrySelectors,[]);/*find the exact styleName in the stylemanager or if that doesn't exist then create a new style to merge partily matched styles*/
        for weightStyle:WeightedStyle in weightedStyles{/*compiles the finalStyle by making sure the last selector matches the last selector in the weightstyle, this works different for font etc. which are inheritable*/
            StyleModifier.merge(&finalStyle, StyleAsserter.direct(querrySelectors, weightStyle) ? weightStyle : StyleModifier.filter(weightStyle, CSSConstants.textPropertyNames))/*direct styles will be appart of the final style and  you inherit from indirect styles, fonts,*or properties marked inherit*/
        }
        return finalStyle
    }
}
/**
 * TODO: Deprecate this method, its not doing anything anymore
 */
/*
class func temp_style(element:IElement)->IStyle{
    //let querrySelectors:Array = ElementParser.selectors(element);// :TODO: possibly move up in scope for optimizing
    //Swift.print("STACK: " + SelectorParser.string(querrySelectors));
    var styleComposition:IStyle = Style("styleComp")
    //let classType:String = element.getClassType()//gets the classtype from the component
    let querrySelector:ISelector = ElementParser.selector(element);// :TODO: possibly move up in scope for optimizing
    //Swift.print("styleComposition")
    //Swift.print(StyleManager.styles.count)
    for style in StyleManager.styles{//loop through styles
        //Swift.print("style.selector.element: " + style.selector.element)
        for selector in style.selectors{
            if(selector.element == querrySelector.element){ //if style.selector == classType
                //Swift.print("  element match found")
                if(selector.states.count > 0){
                    for state in selector.states{//loop style.selector.states
                        //Swift.print("state: " + state)
                        //Swift.print("element.skinState: " + element.skinState)
                        for s in querrySelector.states{
                            if(state == s){//if state == any of the current states TODO: figure out how the statemaschine works and impliment that
                                //Swift.print("    state match found")
                                StyleModifier.combine(&styleComposition, style)//gracefully append this style to styleComposition, forced overwrite
                            }
                        }
                    }
                }else{//temp solution
                    StyleModifier.combine(&styleComposition, style)
                }
            }
        }
    }
    //Swift.print("styleComposition.styleProperties.count: " + "\(styleComposition.styleProperties.count)")
    //StyleParser.describe(styleComposition)
    return styleComposition
}
*/