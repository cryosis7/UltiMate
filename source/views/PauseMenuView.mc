using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class PauseMenuView extends ScrollingMenuView {

    private var _view;
    private var _gameModel;
    private var _updateTimer;
    
    function initialize(view, gameModel) {
        ScrollingMenuView.initialize();
        _view = view;
        _gameModel = gameModel;
        _updateTimer = new Timer.Timer();
        _title = "Paused";
        _menuItems = ["Resume", "Save", "Discard"];
    }

    function onShow() {
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    function onHide() {
        _updateTimer.stop();
    }

    function onTimer() {
        WatchUi.requestUpdate();
    }
    
    function getSubheading() {
        return _gameModel.getFormattedPauseDuration(null);
    }
    
    function selectItem() {
        if (_selectedIndex == 0) {
            resume();
        } else if (_selectedIndex == 1) {
            _view.saveSession();
            System.exit();
        } else if (_selectedIndex == 2) {
            _view.discardSession();
            System.exit();
        }
    }
    
    function resume() {
        _view.resume();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}

