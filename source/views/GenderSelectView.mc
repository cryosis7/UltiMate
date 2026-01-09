using Toybox.WatchUi;

class GenderSelectView extends ScrollingMenuView {

    function initialize() {
        ScrollingMenuView.initialize();
        _title = "Starting Gender";
        _menuItems = ["ABBA", "Female", "Male", "Disabled"];
    }

    function selectItem() {
        if (_selectedIndex == 0) {
            Settings.selectedGender = null;
            Settings.genderEnabled = true;
        } else if (_selectedIndex == 1) {
            Settings.selectedGender = "F";
            Settings.genderEnabled = true;
        } else if (_selectedIndex == 2) {
            Settings.selectedGender = "M";
            Settings.genderEnabled = true;
        } else if (_selectedIndex == 3) {
            Settings.genderEnabled = false;
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}
