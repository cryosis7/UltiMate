using Toybox.Lang;
using Toybox.WatchUi;

class GenderSelectDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Lang.Symbol) as Void {
        if (item == :male) {
            Settings.selectedGender = "M";
        } else if (item == :female) {
            Settings.selectedGender = "F";
        } else if (item == :abba) {
            Settings.selectedGender = null;
        }
        
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

}
