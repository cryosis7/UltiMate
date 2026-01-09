using Toybox.WatchUi;

class ConfirmExitDelegate extends WatchUi.BehaviorDelegate {

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
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
