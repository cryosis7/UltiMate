using Toybox.WatchUi;

class UltiMateDelegate extends WatchUi.BehaviorDelegate {

    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        if (!_view.isPaused()) {
            _view.pause();
        }
        var pauseMenuView = new PauseMenuView(_view, _view.getGameModel());
        WatchUi.pushView(pauseMenuView, new PauseMenuDelegate(pauseMenuView), WatchUi.SLIDE_LEFT);
        return true;
    }

    function onPreviousPage() {
        _view.incrementDark();
        return true;
    }

    function onNextPage() {
        _view.incrementLight();
        return true;
    }

    function onBack() {
        if (_view.undoLastScore()) {
            return true; // screen will refresh
        }
        _view.showConfirmExit();
        return true;
    }

}


