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
    private var _centerX;
    private var _lineHeight;
    private var _labelOffset;
    private var _labelFontSize;
    private var _valueFontSize;
    private var _yPointsValue;
    private var _yGenderLabel;
    private var _yGenderValue;
    private var _yTotalTimeLabel;
    private var _yTotalTimeValue;
    private var _yPointTimeLabel;
    private var _yPointTimeValue;
    
    function initialize() {
        View.initialize();
        _gameModel = new GameModel();
        _updateTimer = new Timer.Timer();
        _session = null;
        
        // Start ActivityRecording session
        if (ActivityRecording has :createSession) {
            _session = ActivityRecording.createSession({
                :name => "Ultimate Frisbee",
                :sport => ActivityRecording.SPORT_GENERIC
            });
            if (_session != null && _session has :start) {
                _session.start();
            }
        }
    }

    // Calculate layout positions based on screen dimensions
    function onLayout(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        _labelFontSize = Graphics.FONT_SMALL;
        _valueFontSize = Graphics.FONT_MEDIUM;
        
        _centerX = width / 2;
        _lineHeight = height / 4;
        _labelOffset = FontConstants.FONT_SMALL_HEIGHT;
        
        // Calculate Y positions for each section
        _yPointsValue = _lineHeight / 2;
        
        _yGenderLabel = _lineHeight;
        _yGenderValue = _yGenderLabel + _labelOffset;
        
        _yTotalTimeLabel = _lineHeight * 2;
        _yTotalTimeValue = _yTotalTimeLabel + _labelOffset;
        
        _yPointTimeLabel = _lineHeight * 3;
        _yPointTimeValue = _yPointTimeLabel + _labelOffset;
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
        
        // Draw split score background
        // Left half: Dark (Black background)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, _centerX, _lineHeight);
        
        // Right half: Light (White background)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(_centerX, 0, _centerX, _lineHeight);
        
        // Draw Dark score (left, white text on black)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX / 2, _yPointsValue, _valueFontSize, _gameModel.getScoreDark().toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw Light score (right, black text on white)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX + (_centerX / 2), _yPointsValue, _valueFontSize, _gameModel.getScoreLight().toString(), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Gender
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _yGenderLabel, _labelFontSize, "Gender", Graphics.TEXT_JUSTIFY_CENTER);
        var currentGender = _gameModel.getCurrentGender();
        var nextGender = _gameModel.getNextGender();
        // Draw current gender in white (centered, slightly left)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _yGenderValue, _valueFontSize, currentGender, Graphics.TEXT_JUSTIFY_CENTER);
        // Draw next gender in dark grey - centered, slightly right
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX + 16, _yGenderValue, _valueFontSize, nextGender, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Total Time
        dc.drawText(_centerX, _yTotalTimeLabel, _labelFontSize, "Total Time", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yTotalTimeValue, _valueFontSize, totalTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Point Time
        dc.drawText(_centerX, _yPointTimeLabel, _labelFontSize, "Point Time", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_centerX, _yPointTimeValue, _valueFontSize, pointTimeStr, Graphics.TEXT_JUSTIFY_CENTER);
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

}


