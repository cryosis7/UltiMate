using Toybox.Graphics;
using Toybox.WatchUi;

/**
 * Confirmation view shown when user presses back with no scores to undo.
 * Prompts user to confirm exit without saving.
 */
class ConfirmExitView extends WatchUi.View {
    
    // Layout variables
    private var _centerX;
    private var _centerY;
    private var _messageY;
    private var _selectedIndex; // 0 = Yes, 1 = No
    private var _viewRef;
    
    function initialize(viewRef) {
        View.initialize();
        _selectedIndex = 0; // Default to "Yes"
        _viewRef = viewRef;
    }

    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _centerX = width / 2;
        _centerY = height / 2;
        _messageY = _centerY - FontConstants.FONT_MEDIUM_HEIGHT - FontConstants.FONT_SMALL_HEIGHT;
    }

    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw confirmation message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _messageY, Graphics.FONT_MEDIUM, "Discard and exit?", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _messageY + FontConstants.FONT_MEDIUM_HEIGHT, Graphics.FONT_SMALL, "Your game will not be saved", Graphics.TEXT_JUSTIFY_CENTER);
        
        var optionY = _centerY + FontConstants.FONT_SMALL_HEIGHT;
        
        if (_selectedIndex == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, optionY, Graphics.FONT_MEDIUM, "Yes", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, optionY, Graphics.FONT_SMALL, "Yes", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var noY = optionY + FontConstants.FONT_MEDIUM_HEIGHT + FontConstants.FONT_SMALL_HEIGHT;
        if (_selectedIndex == 1) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, noY, Graphics.FONT_MEDIUM, "No", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, noY, Graphics.FONT_SMALL, "No", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function selectNext() {
        _selectedIndex = (_selectedIndex + 1) % 2;
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() {
        _selectedIndex = (_selectedIndex - 1 + 2) % 2;
        WatchUi.requestUpdate();
    }
    
    function selectItem() {
        if (_selectedIndex == 0) {
            // Yes - discard and exit
            _viewRef.discardSession();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN); // Exit app
        } else {
            // No - cancel and go back
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

}

