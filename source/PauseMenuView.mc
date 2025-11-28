using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

/**
 * Custom pause menu view that displays pause timer and menu options.
 */
class PauseMenuView extends WatchUi.View {

    private var _view;
    private var _gameModel;
    private var _updateTimer;
    private var _selectedIndex;
    
    // Layout variables
    private var _centerX;
    private var _titleY;
    private var _timerY;
    private var _menuStartY;
    private var _smallFontHeight;
    private var _mediumFontHeight;
    
    private const MENU_ITEMS = ["Resume", "Save", "Discard"];
    
    function initialize(view, gameModel) {
        View.initialize();
        _view = view;
        _gameModel = gameModel;
        _updateTimer = new Timer.Timer();
        _selectedIndex = 0; // 0 = Resume, 1 = Save, 2 = Discard
    }

    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _centerX = width / 2;
        _titleY = height * 0.10;
        _timerY = height * 0.30;
        
        // Calculate menu positioning to center the selected item in lower half
        // Use consistent spacing between items
        _menuStartY = height * 0.65;  // Center point for selected item
        _smallFontHeight = FontConstants.FONT_SMALL_HEIGHT;
        _mediumFontHeight = FontConstants.FONT_MEDIUM_HEIGHT;
    }

    function onShow() {
        // Start timer to update pause duration display every second
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    function onHide() {
        _updateTimer.stop();
    }

    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _titleY, Graphics.FONT_MEDIUM, "Paused", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw pause timer
        var pauseTimeStr = _gameModel.getFormattedPauseDuration(null);
        dc.drawText(_centerX, _timerY, Graphics.FONT_SMALL, pauseTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw scrolling menu - show current item large, with prev/next items smaller
        var currentItem = MENU_ITEMS[_selectedIndex];
        var prevIndex = (_selectedIndex - 1 + 3) % 3;
        var nextIndex = (_selectedIndex + 1) % 3;
        
        // Draw current (selected) item - large and centered
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY, Graphics.FONT_MEDIUM, currentItem, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw previous item
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY - _smallFontHeight, Graphics.FONT_SMALL, MENU_ITEMS[prevIndex], Graphics.TEXT_JUSTIFY_CENTER);

        // Draw next item 
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY + _mediumFontHeight, Graphics.FONT_SMALL, MENU_ITEMS[nextIndex], Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onTimer() {
        WatchUi.requestUpdate();
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
            // Resume
            resume();
        } else if (_selectedIndex == 1) {
            // Save
            _view.saveSession();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN); // Exit app after save
        } else if (_selectedIndex == 2) {
            // Discard
            _view.discardSession();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN); // Exit app after discard
        }
    }
    
    function resume() {
        _view.resume();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}

