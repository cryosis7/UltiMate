using Toybox.WatchUi;

class UltiMateDelegate extends WatchUi.InputDelegate {

    private var _view;

    function initialize(view) {
        InputDelegate.initialize();
        _view = view;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        
        // Handle Lap button press
        if (key == WatchUi.KEY_LAP || key == WatchUi.KEY_ENTER) {
            _view.incrementPoint();
            WatchUi.requestUpdate();
            return true;
        }
        
        return false;
    }

}


