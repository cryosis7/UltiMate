using Toybox.System;
using Toybox.WatchUi;

class StartMenuView extends ScrollingMenuView {
    
    function initialize() {
        ScrollingMenuView.initialize();
        _title = "Ulti-Mate";
        _menuItems = ["Start", "Settings", "Exit"];
    }
    
    function selectItem() {
        if (_selectedIndex == 0) {
            var gameView = new UltiMateView(Settings.selectedGender);
            WatchUi.switchToView(gameView, new UltiMateDelegate(gameView), WatchUi.SLIDE_LEFT);
        } else if (_selectedIndex == 1) {
            var settingsView = new SettingsMenuView();
            WatchUi.pushView(settingsView, new SettingsMenuDelegate(settingsView), WatchUi.SLIDE_LEFT);
        } else if (_selectedIndex == 2) {
            System.exit();
        }
    }

}
