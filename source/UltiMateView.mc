using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

/**
 * Main view for the Ulti-Mate application.
 * 
 * Displays game timing, scoring, and gender ratio indicators for Ultimate Frisbee.
 * 
 * Timer Logic:
 * - Game timer tracks total elapsed time since app start
 * - Point timer tracks duration of current point (resets when point is incremented)
 * 
 * Gender Ratio Logic (ABBA Pattern):
 * - Follows standard Ultimate Frisbee gender ratio pattern: A, B, B, A...
 */
class UltiMateView extends WatchUi.View {

    private var _gameStartTime;
    private var _pointStartTime;
    private var _pointsCompleted;
    private var _updateTimer;
    private var _currentGender;
    private var _showExitPrompt;
    private var _exitPromptStartTime;
    
    // Layout variables
    private var _centerX;
    private var _lineHeight;
    private var _labelOffset;
    private var _yPointsLabel;
    private var _yPointsValue;
    private var _yGenderLabel;
    private var _yGenderValue;
    private var _yTotalTimeLabel;
    private var _yTotalTimeValue;
    private var _yPointTimeLabel;
    private var _yPointTimeValue;
    
    function initialize() {
        View.initialize();
        _gameStartTime = System.getTimer();
        _pointStartTime = _gameStartTime;
        _pointsCompleted = 0;
        _updateTimer = new Timer.Timer();
        _currentGender = getGenderForPoint(_pointsCompleted);
        _showExitPrompt = false;
        _exitPromptStartTime = 0;
    }

    // Calculate layout positions based on screen dimensions
    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _centerX = width / 2;
        _lineHeight = height / 5;
        _labelOffset = 15;
        
        var startY = height * 0.08;
        
        // Calculate Y positions for each section
        _yPointsLabel = startY;
        _yPointsValue = _yPointsLabel + _labelOffset;
        
        _yGenderLabel = _yPointsValue + _lineHeight - _labelOffset;
        _yGenderValue = _yGenderLabel + _labelOffset;
        
        _yTotalTimeLabel = _yGenderValue + _lineHeight - _labelOffset;
        _yTotalTimeValue = _yTotalTimeLabel + _labelOffset;
        
        _yPointTimeLabel = _yTotalTimeValue + _lineHeight - _labelOffset;
        _yPointTimeValue = _yPointTimeLabel + _labelOffset;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var currentTime = System.getTimer();
        var totalElapsed = currentTime - _gameStartTime;
        var pointElapsed = currentTime - _pointStartTime;
        
        // Check if exit prompt should be hidden (after 2 seconds)
        if (_showExitPrompt && _exitPromptStartTime > 0) {
            var promptElapsed = currentTime - _exitPromptStartTime;
            if (promptElapsed > 2000) {
                _showExitPrompt = false;
                _exitPromptStartTime = 0;
            }
        }
        
        // Format time strings
        var totalTimeStr = formatTime(totalElapsed);
        var pointTimeStr = formatTime(pointElapsed);
        
        // Set text color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var fontSize = Graphics.FONT_SMALL;
        
        // Total Points
        dc.drawText(_centerX, _yPointsLabel, Graphics.FONT_TINY, "Points", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yPointsValue, fontSize, _pointsCompleted.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Gender
        dc.drawText(_centerX, _yGenderLabel, Graphics.FONT_TINY, "Gender", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yGenderValue, fontSize, _currentGender, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Total Time
        dc.drawText(_centerX, _yTotalTimeLabel, Graphics.FONT_TINY, "Total Time", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yTotalTimeValue, fontSize, totalTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Point Time
        dc.drawText(_centerX, _yPointTimeLabel, Graphics.FONT_TINY, "Point Time", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yPointTimeValue, fontSize, pointTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Show exit prompt if needed
        if (_showExitPrompt) {
            var promptY = dc.getHeight() - 30;
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, promptY, Graphics.FONT_TINY, "Press Back again to exit", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        _updateTimer.stop();
    }

    // Timer callback to update the display
    function onTimer() as Void {
        WatchUi.requestUpdate();
    }
    
    // Public methods for delegate to call
    function incrementPoint() as Void {
        _pointsCompleted += 1;
        _pointStartTime = System.getTimer();
        _currentGender = getGenderForPoint(_pointsCompleted);
    }
    
    function getPointsCompleted() {
        return _pointsCompleted;
    }
    
    // Show exit prompt message
    function showExitPrompt() as Void {
        _showExitPrompt = true;
        _exitPromptStartTime = System.getTimer();
        WatchUi.requestUpdate();
    }
    
    // Helper method: Calculate gender ratio based on ABBA pattern
    // Points 0,3,4,7,8,11,12... = A (when points_completed % 4 == 0 || points_completed % 4 == 3)
    // Points 1,2,5,6,9,10... = B (when points_completed % 4 == 1 || points_completed % 4 == 2)
    private function getGenderForPoint(points) {
        if (points == 0) {
            return "A";
        }
        var mod = points % 4;
        if (mod == 1 || mod == 2) {
            return "B";
        }
        return "A";
    }
    
    // Helper method: Format milliseconds as MM:SS string
    private function formatTime(milliseconds) {
        var minutes = milliseconds / 60000;
        var seconds = (milliseconds / 1000) % 60;
        return minutes.format("%d") + ":" + seconds.format("%02d");
    }

}


