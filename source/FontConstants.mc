using Toybox.Graphics;

/**
 * Global font height constants.
 * These are calculated once on app initialization and reused throughout the application.
 */
module FontConstants {
    
    // Font height constants - initialized once
    var FONT_TINY_HEIGHT = null;
    var FONT_SMALL_HEIGHT = null;
    var FONT_MEDIUM_HEIGHT = null;
    var FONT_LARGE_HEIGHT = null;
    var FONT_NUMBER_MILD_HEIGHT = null;
    var FONT_NUMBER_MEDIUM_HEIGHT = null;
    var FONT_NUMBER_HOT_HEIGHT = null;
    var FONT_NUMBER_THAI_HOT_HEIGHT = null;
    
    /**
     * Initialize all font height constants.
     * Should be called once during app initialization.
     */
    function initialize() {
        FONT_TINY_HEIGHT = Graphics.getFontHeight(Graphics.FONT_TINY);
        FONT_SMALL_HEIGHT = Graphics.getFontHeight(Graphics.FONT_SMALL);
        FONT_MEDIUM_HEIGHT = Graphics.getFontHeight(Graphics.FONT_MEDIUM);
        FONT_LARGE_HEIGHT = Graphics.getFontHeight(Graphics.FONT_LARGE);
        FONT_NUMBER_MILD_HEIGHT = Graphics.getFontHeight(Graphics.FONT_NUMBER_MILD);
        FONT_NUMBER_MEDIUM_HEIGHT = Graphics.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
        FONT_NUMBER_HOT_HEIGHT = Graphics.getFontHeight(Graphics.FONT_NUMBER_HOT);
        FONT_NUMBER_THAI_HOT_HEIGHT = Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT);
    }
    
}

