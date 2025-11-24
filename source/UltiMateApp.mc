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

    // Return the initial view of your application here
    function getInitialView() {
        var view = new UltiMateView();
        return [ view, new UltiMateDelegate(view) ];
    }

}

