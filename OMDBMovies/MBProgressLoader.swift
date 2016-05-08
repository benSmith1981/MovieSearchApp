/**
 Helper class to implement the MBProgress HUD and simplify calling it
 */

import UIKit
import MBProgressHUD

class MBProgressLoader:  NSObject {
    
    class func Show(message:String = "loading...",delegate:UIViewController){
        var load : MBProgressHUD = MBProgressHUD()
        load = MBProgressHUD.showHUDAddedTo(delegate.view, animated: true)
        load.mode = MBProgressHUDMode.Indeterminate
        load.labelText = message;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    class func Hide(delegate:UIViewController){
        MBProgressHUD.hideHUDForView(delegate.view, animated: true)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    
    class func Show(message:String = "loading..."){
        var load : MBProgressHUD = MBProgressHUD()
        load = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow!, animated: true)
        load.mode = MBProgressHUDMode.Indeterminate
        load.labelText = message;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    class func Hide(){
        MBProgressHUD.hideHUDForView(UIApplication.sharedApplication().keyWindow!, animated: true)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
