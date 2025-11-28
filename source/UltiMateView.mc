using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.WatchUi;
using Toybox.ActivityRecording;

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

    private var _gameModel;
    private var _updateTimer;
    private var _session;
    
    // Layout variables
    private var _width;
    private var _labelOffset;
    private var _labelFontSize;
    private var _valueFontSize;
    private var _yOneThird;
    private var _ySection1;
    private var _ySection2;
    private var _xCenter;
    private var _xFirstQuarter;
    private var _xThirdQuarter;
    
    private var _xScoreDarkPos;
    private var _xScoreLightPos;
    private var _yScorePos;
    private var _yCurrentTimePos;
    private var _yTimerLabelPos;
    private var _yTimerValuePos;
    private var _xGenderNextPos;
    
    function initialize() {
        View.initialize();
        _gameModel = new GameModel();
        _updateTimer = new Timer.Timer();
        _session = null;
        
        // Start ActivityRecording session
        if (ActivityRecording has :createSession) {
            _session = ActivityRecording.createSession({
                :name => "UltimateFrisbee",
                :sport => ActivityRecording.SPORT_GENERIC
            });
            if (_session != null && _session has :start) {
                _session.start();
            }
        }
    }

    // Calculate layout positions based on screen dimensions
    function onLayout(dc) {
        _labelFontSize = Graphics.FONT_TINY;
        _labelOffset = FontConstants.FONT_TINY_HEIGHT;
        _valueFontSize = Graphics.FONT_LARGE;
        
        var height = dc.getHeight();

        _yOneThird = height / 3;
        var buffer = _yOneThird * 0.2;
        _ySection1 = _yOneThird - buffer;
        _ySection2 = (_yOneThird * 2) + buffer;
        
        _width = dc.getWidth();
        _xCenter = _width / 2;
        _xFirstQuarter = _width / 4;
        _xThirdQuarter = _width - _xFirstQuarter;
        
        _xScoreDarkPos = _xCenter * 0.66;
        _xScoreLightPos = _xCenter * 1.33;
        _yScorePos = _ySection1 / 2;
        
        var middleSectionHeight = _ySection2 - _ySection1;
        _yCurrentTimePos = _ySection1 + (middleSectionHeight * 0.25);
        _yTimerLabelPos = _ySection1 + (middleSectionHeight * 0.5);
        _yTimerValuePos = _ySection1 + (middleSectionHeight * 0.75);
        
        _xGenderNextPos = _xCenter * 1.25;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        if (!_gameModel.isPaused()) {
            _updateTimer.start(method(:onTimer), 1000, true);
        }
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Get formatted time strings from model
        var totalTimeStr = _gameModel.getFormattedTotalTime(null);
        var pointTimeStr = _gameModel.getFormattedPointTime(null);
        var clockTime = System.getClockTime();
        var currentTimeStr = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");

        // Draw split score background
        // Left half: Dark (Black background)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, _xCenter, _ySection1);
        
        // Right half: Light (White background)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(_xCenter, 0, _xCenter, _ySection1);

        // White outline around the score
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0, 0, _width, _ySection1);

        // Draw Dark score (left, white text on black) at 66% of the way across it's section
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xScoreDarkPos, _yScorePos, Graphics.FONT_NUMBER_MILD, _gameModel.getScoreDark().toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw Light score (right, black text on white) at 33% of the way across it's section
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xScoreLightPos, _yScorePos, Graphics.FONT_NUMBER_MILD, _gameModel.getScoreLight().toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ------------------------------------------------------------
        // Current Time (Centered)
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xCenter, _yCurrentTimePos, Graphics.FONT_TINY, currentTimeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Total Time (Left half)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xFirstQuarter, _yTimerLabelPos, _labelFontSize, "Total", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_xFirstQuarter, _yTimerValuePos, Graphics.FONT_NUMBER_MILD, totalTimeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Point Time (Right half)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xThirdQuarter, _yTimerLabelPos, _labelFontSize, "Point", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_xThirdQuarter, _yTimerValuePos, Graphics.FONT_NUMBER_MILD, pointTimeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // ------------------------------------------------------------

        // Gender
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xCenter, _ySection2, _labelFontSize, "Gender", Graphics.TEXT_JUSTIFY_CENTER);
        // Draw current gender in white (centered)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xCenter, _ySection2 + _labelOffset, _valueFontSize, _gameModel.getCurrentGender(), Graphics.TEXT_JUSTIFY_CENTER);
        // Draw next gender in dark grey - centered, slightly right
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_xGenderNextPos, _ySection2 + _labelOffset, _valueFontSize, _gameModel.getNextGender(), Graphics.TEXT_JUSTIFY_CENTER);
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
    function incrementDark() as Void {
        _gameModel.incrementDark(null);
        WatchUi.requestUpdate();
    }
    
    function incrementLight() as Void {
        _gameModel.incrementLight(null);
        WatchUi.requestUpdate();
    }
    
    function pause() as Void {
        _gameModel.pause(null);
        _updateTimer.stop();
    }
    
    function resume() as Void {
        _gameModel.resume(null);
        WatchUi.requestUpdate();
    }
    
    function saveSession() as Void {
        if (_session != null && _session has :stop) {
            _session.stop();
        }
        if (_session != null && _session has :save) {
            _session.save();
        }
        _session = null;
    }
    
    function discardSession() as Void {
        if (_session != null && _session has :stop) {
            _session.stop();
        }
        if (_session != null && _session has :discard) {
            _session.discard();
        }
        _session = null;
    }
    
    function isPaused() {
        return _gameModel.isPaused();
    }
    
    function getGameModel() {
        return _gameModel;
    }

    /**
     * Undo the last score that was added.
     * @return true if a score was undone, false if history is empty.
     */
    function undoLastScore() {
        var undone = _gameModel.undoLastScore(null);
        if (undone) {
            WatchUi.requestUpdate();
        }
        return undone;
    }

    /**
     * Show the confirm exit view when user presses back with no scores.
     */
    function showConfirmExit() as Void {
        var confirmExitView = new ConfirmExitView(self);
        WatchUi.pushView(confirmExitView, new ConfirmExitDelegate(confirmExitView), WatchUi.SLIDE_UP);
    }

    /**
     * Cleanup resources when the application is exiting.
     * Called from UltiMateApp.onStop() to ensure proper resource cleanup.
     */
    function cleanup() as Void {
        if (_updateTimer != null) {
            _updateTimer.stop();
            _updateTimer = null;
        }
        if (_session != null) {
            if (_session has :stop) {
                _session.stop();
            }
            if (_session has :discard) {
                _session.discard();
            }
            _session = null;
        }
        _gameModel = null;
    }

}


