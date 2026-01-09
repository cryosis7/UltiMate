using Toybox.Graphics;
using Toybox.WatchUi;

class ScrollingMenuView extends WatchUi.View {

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
        
        var currentItem = _menuItems[_selectedIndex];
        var prevIndex = (_selectedIndex - 1 + menuItemCount) % menuItemCount;
        var nextIndex = (_selectedIndex + 1) % menuItemCount;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY, Graphics.FONT_MEDIUM, currentItem, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _menuStartY - _smallFontHeight, Graphics.FONT_SMALL, _menuItems[prevIndex], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _menuStartY + _mediumFontHeight, Graphics.FONT_SMALL, _menuItems[nextIndex], Graphics.TEXT_JUSTIFY_CENTER);
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
