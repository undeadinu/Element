import Foundation

class StyleResolverUtils {
    /**
     * Return an array of WeightedStyle instances
     * NOTE: while loading the Basic.css flat structure queries 97656  vs treestructure queries 13324 (this is why we use a treestructure querey technique)
     */
    static func query(_ querySelectors:[SelectorKind],_ searchTree:[String:Any],_ cursor:Int = 0) -> [WeightedStyle]{
        var weightedStyles:[WeightedStyle] = []
        let querySelectorsCount = querySelectors.count/*optimization*/
        //var styles:[IStyle] = []
        for key in searchTree.keys {
            //print("key: " + key + " object: "+searchTree[key] + " at cursor: "+cursor);
            if(key == "style") {weightedStyles.append(WeightedStyle(searchTree[key] as! Stylable, StyleWeight([])))}
            else{
                let keySelector:SelectorKind = SelectorParser.selector(key)/*expand the selectorString to a selector*/
                for i in cursor..<querySelectorsCount{//<--swift 3 support, was--> for (var i : Int = cursor; i < querySelectorsCount; i++) {
                    StyleResolver.styleLookUpCount += 1
                    let querySelector:SelectorKind = querySelectors[i]
                    if(SelectorAsserter.hasCommonality(keySelector, querySelector)){
                        //print("matching element found, keep digging deeper");
                        let result:[WeightedStyle] = query(querySelectors, searchTree[key] as! [String:Any],i+1)
                        if(result.count > 0) {weightedStyles += result}
                    }
                }
            }
        }
        return weightedStyles
    }
}
