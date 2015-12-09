import Foundation

class DecoratorParser {
    /**
     * Returns a Decorator instance from @param decoratable by Class type @param classType if it exists, if it doesnt it returns null
     */
    class func decoratable(decoratable:IGraphicDecoratable,_ classType:Any)->IGraphicDecoratable {
        
        //continue here, assert a decoratable with you class assertion code
        
        if(decoratable is classType) {
            return decoratable;
        }
        var current:IGraphicDecoratable = decoratable;
        while(current.decoratable != current) {
            if(current.decoratable is classType) {
                return current.decoratable;
            }
            current = current.decoratable;
        }
        return nil;
    }
}
