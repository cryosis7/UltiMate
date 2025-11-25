using Toybox.System;
using Toybox.WatchUi;

class UltiMateDelegate extends WatchUi.InputDelegate {

    private var _view;
    private var _lastBackPressTime; // Timestamp of last back button press

    function initialize(view) {
        InputDelegate.initialize();
        _view = view;
        _lastBackPressTime = 0;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        
        // Handle Lap button press
        if (key == WatchUi.KEY_LAP || key == WatchUi.KEY_ENTER) {
            _view.incrementPoint();
            WatchUi.requestUpdate();
            return true;
        }
        
        // Handle Back button (KEY_ESC) - require double press to exit
        if (key == WatchUi.KEY_ESC) {
            var currentTime = System.getTimer();
            var timeSinceLastPress = currentTime - _lastBackPressTime;
            
            // If pressed within 2 seconds of last press, allow exit
            if (_lastBackPressTime > 0 && timeSinceLastPress < 2000) {
                return false; // Allow default exit behavior
            }
            
            // Otherwise, record this press and show prompt
            _lastBackPressTime = currentTime;
            _view.showExitPrompt();
            return true; // Block exit
        }
        
        return false;
    }

}


