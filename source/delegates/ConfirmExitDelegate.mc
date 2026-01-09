using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class ConfirmExitDelegate extends WatchUi.MenuInputDelegate {

    private var _viewRef;

    function initialize(viewRef) {
        MenuInputDelegate.initialize();
        _viewRef = viewRef;
    }

    function onMenuItem(item as Lang.Symbol) as Void {
        if (item == :yes) {
            _viewRef.discardSession();
            System.exit();
        } else if (item == :no) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

}
