using Toybox.Graphics;
using Toybox.WatchUi;

class StaticMenuView extends WatchUi.View {

    protected var _title;
    protected var _menuItems;
    protected var _selectedIndex;
    
    protected var _centerX;
    protected var _titleY;
    protected var _subheadingY;
    protected var _menuStartY;
    protected var _smallFontHeight;
    protected var _mediumFontHeight;
    protected var _largeFontHeight;
    
    function initialize() {
        View.initialize();
        _selectedIndex = 0;
        _title = "";
        _menuItems = [];
    }

    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _centerX = width / 2;
        _smallFontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);
        _mediumFontHeight = Graphics.getFontHeight(Graphics.FONT_MEDIUM);
        _largeFontHeight = Graphics.getFontHeight(Graphics.FONT_LARGE);
        
        var subheading = getSubheading();
        if (subheading != null) {
            _titleY = height * 0.10;
            _subheadingY = height * 0.30;
            _menuStartY = height * 0.65;
        } else {
            _titleY = height * 0.15;
            _menuStartY = height * 0.50;
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var subheading = getSubheading();
        if (subheading != null) {
            dc.drawText(_centerX, _titleY, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(_centerX, _subheadingY, Graphics.FONT_SMALL, subheading, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(_centerX, _titleY, Graphics.FONT_LARGE, _title, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        drawMenu(dc);
    }
    
    function getSubheading() {
        return null;
    }
    
    function drawMenu(dc) {
        var menuItemCount = _menuItems.size();
        if (menuItemCount == 0) {
            return;
        }
        
        var item0Y = _menuStartY;
        var item1Y = _menuStartY + _mediumFontHeight + _smallFontHeight;
        
        if (_selectedIndex == 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, item0Y, Graphics.FONT_MEDIUM, _menuItems[0], Graphics.TEXT_JUSTIFY_CENTER);
            
            if (menuItemCount > 1) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(_centerX, item1Y, Graphics.FONT_SMALL, _menuItems[1], Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, item0Y, Graphics.FONT_SMALL, _menuItems[0], Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, item1Y, Graphics.FONT_MEDIUM, _menuItems[1], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function getSelectedIndex() {
        return _selectedIndex;
    }
    
    function selectNext() {
        var menuItemCount = _menuItems.size();
        _selectedIndex = (_selectedIndex + 1) % menuItemCount;
        WatchUi.requestUpdate();
    }
    
    function selectPrevious() {
        var menuItemCount = _menuItems.size();
        _selectedIndex = (_selectedIndex - 1 + menuItemCount) % menuItemCount;
        WatchUi.requestUpdate();
    }
    
    function selectItem() {
    }

}
