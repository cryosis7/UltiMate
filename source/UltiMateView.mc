using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;

class UltiMateView extends WatchUi.View {

    private var _gameStartTime;
    private var _pointStartTime;
    private var _pointsCompleted;
    private var _updateTimer;
    
    function initialize() {
        View.initialize();
        _gameStartTime = System.getTimer();
        _pointStartTime = _gameStartTime;
        _pointsCompleted = 0;
        _updateTimer = new Timer.Timer();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _updateTimer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        var currentTime = System.getTimer();
        var totalElapsed = currentTime - _gameStartTime;
        var pointElapsed = currentTime - _pointStartTime;
        
        // Calculate gender based on ABBA pattern: A, B, B, A, A, B, B...
        // Pattern: points 0,3,4,7,8,11,12... = A (when points_completed % 4 == 0 || points_completed % 4 == 3)
        // Pattern: points 1,2,5,6,9,10... = B (when points_completed % 4 == 1 || points_completed % 4 == 2)
        var gender = "A";
        if (_pointsCompleted > 0) {
            var mod = _pointsCompleted % 4;
            if (mod == 1 || mod == 2) {
                gender = "B";
            }
        }
        
        // Format time as MM:SS
        var totalMinutes = totalElapsed / 60000;
        var totalSeconds = (totalElapsed / 1000) % 60;
        var pointMinutes = pointElapsed / 60000;
        var pointSeconds = (pointElapsed / 1000) % 60;
        
        var totalTimeStr = totalMinutes.format("%d") + ":" + totalSeconds.format("%02d");
        var pointTimeStr = pointMinutes.format("%d") + ":" + pointSeconds.format("%02d");
        
        // Get screen dimensions
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        // Set text color
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw labels and values
        var yPos = 20;
        var lineHeight = 30;
        var fontSize = Graphics.FONT_SMALL;
        
        // Total Points
        dc.drawText(centerX, yPos, Graphics.FONT_TINY, "Points", Graphics.TEXT_JUSTIFY_CENTER);
        yPos += 15;
        dc.drawText(centerX, yPos, fontSize, _pointsCompleted.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        yPos += lineHeight;
        
        // Gender
        dc.drawText(centerX, yPos, Graphics.FONT_TINY, "Gender", Graphics.TEXT_JUSTIFY_CENTER);
        yPos += 15;
        dc.drawText(centerX, yPos, fontSize, gender, Graphics.TEXT_JUSTIFY_CENTER);
        yPos += lineHeight;
        
        // Total Time
        dc.drawText(centerX, yPos, Graphics.FONT_TINY, "Total Time", Graphics.TEXT_JUSTIFY_CENTER);
        yPos += 15;
        dc.drawText(centerX, yPos, fontSize, totalTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
        yPos += lineHeight;
        
        // Point Time
        dc.drawText(centerX, yPos, Graphics.FONT_TINY, "Point Time", Graphics.TEXT_JUSTIFY_CENTER);
        yPos += 15;
        dc.drawText(centerX, yPos, fontSize, pointTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
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
    }
    
    function getPointsCompleted() as Number {
        return _pointsCompleted;
    }

}


