using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;

class StartMenuViewDelegate extends WatchUi.BehaviorDelegate {

    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() {
        _view.selectNext();
        return true;
    }

    function onPreviousPage() {
        _view.selectPrevious();
        return true;
    }

    function onSelect() {
        _view.selectItem();
        return true;
    }

}
