using Toybox.Application;
using Toybox.System;
using Toybox.WatchUi;

class UltiMateApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    function getInitialView() {
        var view = new StartMenuView();
        return [view, new StartMenuViewDelegate(view)];
    }

}

