using Toybox.System;
using Toybox.WatchUi;

class ConfirmExitView extends StaticMenuView {

    private var _viewRef;

    function initialize(viewRef) {
        StaticMenuView.initialize();
        _viewRef = viewRef;
        _title = "Exit?";
        _menuItems = ["Yes", "No"];
    }

    function selectItem() {
        if (_selectedIndex == 0) {
            _viewRef.discardSession();
            System.exit();
        } else if (_selectedIndex == 1) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

}
