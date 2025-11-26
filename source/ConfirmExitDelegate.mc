using Toybox.WatchUi;

/**
 * Delegate for the confirm exit view to handle button input.
 */
class ConfirmExitDelegate extends WatchUi.BehaviorDelegate {

    private var _viewRef;

    function initialize(viewRef) {
        BehaviorDelegate.initialize();
        _viewRef = viewRef;
    }

    function onSelect() {
        _viewRef.selectItem();
        return true;
    }
    
    function onNextPage() {
        _viewRef.selectNext();
        return true;
    }
    
    function onPreviousPage() {
        _viewRef.selectPrevious();
        return true;
    }
    
    function onBack() {
        // Cancel - just go back (same as selecting "No")
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}

