using Toybox.WatchUi;

/**
 * Delegate for the pause menu to handle button input for the custom pause menu view.
 */
class PauseMenuDelegate extends WatchUi.BehaviorDelegate {

    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        _view.selectItem();
        return true;
    }
    
    function onNextPage() {
        _view.selectNext();
        return true;
    }
    
    function onPreviousPage() {
        _view.selectPrevious();
        return true;
    }
    
    function onBack() {
        _view.resume();
        return true;
    }

}

