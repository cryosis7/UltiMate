using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class StartMenuView extends WatchUi.View {

    private var _selectedIndex;
    
    private var _centerX;
    private var _titleY;
    private var _menuStartY;
    private var _smallFontHeight;
    private var _mediumFontHeight;
    
    private const MENU_ITEMS = ["Start", "Settings", "Exit"];
    
    function initialize() {
        View.initialize();
        _selectedIndex = 0;
    }

    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _centerX = width / 2;
        _titleY = height * 0.15;
        _menuStartY = height * 0.50;
        _smallFontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);
        _mediumFontHeight = Graphics.getFontHeight(Graphics.FONT_MEDIUM);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _titleY, Graphics.FONT_LARGE, "Ulti-Mate", Graphics.TEXT_JUSTIFY_CENTER);
        
        var currentItem = MENU_ITEMS[_selectedIndex];
        var prevIndex = (_selectedIndex - 1 + 3) % 3;
        var nextIndex = (_selectedIndex + 1) % 3;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY, Graphics.FONT_MEDIUM, currentItem, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY - _smallFontHeight, Graphics.FONT_SMALL, MENU_ITEMS[prevIndex], Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY + _mediumFontHeight, Graphics.FONT_SMALL, MENU_ITEMS[nextIndex], Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function getSelectedIndex() {
        return _selectedIndex;
    }
    
    function selectNext() {
        _selectedIndex = (_selectedIndex + 1) % 3;
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() {
        _selectedIndex = (_selectedIndex - 1 + 3) % 3;
        WatchUi.requestUpdate();
    }
    
    function selectItem() {
        if (_selectedIndex == 0) {
            var gameView = new UltiMateView(Settings.selectedGender);
            WatchUi.switchToView(gameView, new UltiMateDelegate(gameView), WatchUi.SLIDE_LEFT);
        } else if (_selectedIndex == 1) {
            var settingsMenu = new WatchUi.Menu();
            settingsMenu.setTitle("Settings");
            
            var genderLabel = "Gender: ";
            if (Settings.selectedGender == null) {
                genderLabel += "ABBA";
            } else if (Settings.selectedGender.equals("M")) {
                genderLabel += "M";
            } else {
                genderLabel += "F";
            }
            settingsMenu.addItem(genderLabel, :gender);
            settingsMenu.addItem("Back", :back);
            
            WatchUi.pushView(settingsMenu, new SettingsMenuDelegate(), WatchUi.SLIDE_LEFT);
        } else if (_selectedIndex == 2) {
            System.exit();
        }
    }

}
