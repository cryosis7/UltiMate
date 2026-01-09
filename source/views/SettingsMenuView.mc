using Toybox.WatchUi;

class SettingsMenuView extends StaticMenuView {

    function initialize() {
        StaticMenuView.initialize();
        _title = "Settings";
        updateMenuItems();
    }

    function onShow() {
        updateMenuItems();
        WatchUi.requestUpdate();
    }

    function updateMenuItems() {
        var genderLabel = "Gender: ";
        if (!Settings.genderEnabled) {
            genderLabel += "Disabled";
        } else if (Settings.selectedGender == null) {
            genderLabel += "ABBA";
        } else if (Settings.selectedGender.equals("M")) {
            genderLabel += "M";
        } else {
            genderLabel += "F";
        }
        _menuItems = [genderLabel, "Back"];
    }

    function selectItem() {
        if (_selectedIndex == 0) {
            var genderView = new GenderSelectView();
            WatchUi.pushView(genderView, new GenderSelectDelegate(genderView), WatchUi.SLIDE_LEFT);
        } else if (_selectedIndex == 1) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

}
