using Toybox.Lang;
using Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Lang.Symbol) as Void {
        if (item == :gender) {
            var genderMenu = new WatchUi.Menu();
            genderMenu.setTitle("Starting Gender");
            genderMenu.addItem("ABBA", :abba);
            genderMenu.addItem("Female", :female);
            genderMenu.addItem("Male", :male);
            
            WatchUi.pushView(genderMenu, new GenderSelectDelegate(), WatchUi.SLIDE_LEFT);
        } else if (item == :back) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

}
