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
    private var _yesY;
    private var _noY;
    private var _selectedIndex; // 0 = Yes, 1 = No
    private var _viewRef;

    private var _headingFont = Graphics.FONT_MEDIUM;
    private var _optionSelectedFont = Graphics.FONT_MEDIUM;
    private var _optionUnselectedFont = Graphics.FONT_SMALL;
    
    function initialize(viewRef) {
        View.initialize();
        _selectedIndex = 0; // Default to "Yes"
        _viewRef = viewRef;
    }

    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        System.println("Size: " + width + "x" + height);

        if (width <= 240) {
            _headingFont = Graphics.FONT_SMALL;
        }
        
        _centerX = width / 2;
        _centerY = height / 2;
        _messageY = _centerY - (2 * Graphics.getFontHeight(_headingFont));
        _yesY = _centerY;
        _noY = _yesY + FontConstants.FONT_MEDIUM_HEIGHT + Graphics.getFontDescent(Graphics.FONT_SMALL);

    }

    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw confirmation message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _messageY, _headingFont, "Discard and exit?", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw Yes option
        if (_selectedIndex == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _yesY, _optionSelectedFont, "Yes", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _yesY, _optionUnselectedFont, "Yes", Graphics.TEXT_JUSTIFY_CENTER);
        }
         
        // Draw No option
        if (_selectedIndex == 1) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _noY, _optionSelectedFont, "No", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _noY, _optionUnselectedFont, "No", Graphics.TEXT_JUSTIFY_CENTER);
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
            System.exit();
        } else {
            // No - cancel and go back
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

}

