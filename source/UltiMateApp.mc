using Toybox.Application;
using Toybox.System;
using Toybox.WatchUi;

class UltiMateApp extends Application.AppBase {

    private var _mainView;

    function initialize() {
        AppBase.initialize();
        FontConstants.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if (_mainView != null) {
            _mainView.cleanup();
            _mainView = null;
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        _mainView = new UltiMateView();
        return [ _mainView, new UltiMateDelegate(_mainView) ];
    }

}

