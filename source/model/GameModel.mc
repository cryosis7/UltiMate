using Toybox.System;
using Toybox.ActivityRecording;
using Toybox.Position;

/**
 * GameModel manages the core game state and logic for Ulti-Mate.
 * 
 * This class separates business logic from UI concerns.
 * 
 * Responsibilities:
 * - Track scores (dark and light teams)
 * - Track timing (game start, point start, pause state)
 * - Calculate derived state (current gender ratio, formatted time strings)
 * - Handle game actions (incrementScore, pause, resume)
 * - Manage ActivityRecording session lifecycle
 */
class GameModel {

    private const POINT_DARK = 0;
    private const POINT_LIGHT = 1;
    private const MAX_HISTORY_SIZE = 50;

    private var _gameStartTime;
    private var _pointStartTime;
    private var _scoreDark;
    private var _scoreLight;
    private var _isPaused;
    private var _pauseStartTime;
    private var _currentGender;
    private var _nextGender;
    private var _historyPoints;
    private var _historyPointStartTimes;
    private var _session;
    private var _startingGender;

    function initialize(startingGender) {
        var now = System.getTimer();
        _gameStartTime = now;
        _pointStartTime = now;
        _scoreDark = 0;
        _scoreLight = 0;
        _isPaused = false;
        _pauseStartTime = null;
        _startingGender = startingGender;
        setGender();
        _historyPoints = [];
        _historyPointStartTimes = [];
        _session = null;
        
        if (ActivityRecording has :createSession) {
            _session = ActivityRecording.createSession({
                :name => "UltimateFrisbee",
                :sport => ActivityRecording.SPORT_GENERIC,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC
            });
            if (_session != null && _session has :start) {
                _session.start();
            }
        }
        
        if (Position has :enableLocationEvents) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        }
    }

    /**
     * Increment score for the dark team and start a new point.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function incrementDark(currentTime) as Void {
        if (!_isPaused) {
            var now = (currentTime != null) ? currentTime : System.getTimer();
            _historyPoints.add(POINT_DARK);
            _historyPointStartTimes.add(_pointStartTime);
            if (_historyPoints.size() > MAX_HISTORY_SIZE) {
                _historyPoints = _historyPoints.slice(-MAX_HISTORY_SIZE, null);
                _historyPointStartTimes = _historyPointStartTimes.slice(-MAX_HISTORY_SIZE, null);
            }
            _scoreDark += 1;
            newPoint(now);
        }
    }

    /**
     * Increment score for the light team and start a new point.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function incrementLight(currentTime) as Void {
        if (!_isPaused) {
            var now = (currentTime != null) ? currentTime : System.getTimer();
            _historyPoints.add(POINT_LIGHT);
            _historyPointStartTimes.add(_pointStartTime);
            if (_historyPoints.size() > MAX_HISTORY_SIZE) {
                _historyPoints = _historyPoints.slice(-MAX_HISTORY_SIZE, null);
                _historyPointStartTimes = _historyPointStartTimes.slice(-MAX_HISTORY_SIZE, null);
            }
            _scoreLight += 1;
            newPoint(now);
        }
    }

    /**
     * Start a new point, resetting the point timer and updating gender ratio.
     * @param currentTime Current time in milliseconds.
     */
    private function newPoint(currentTime) as Void {
        _pointStartTime = currentTime;
        setGender();
    }

    /**
     * Pause the game timer.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function pause(currentTime) as Void {
        if (!_isPaused) {
            _isPaused = true;
            _pauseStartTime = (currentTime != null) ? currentTime : System.getTimer();
        }
    }

    /**
     * Resume the game timer, adjusting for pause duration.
     * Only adjusts point timer since total time continues during pause.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function resume(currentTime) as Void {
        if (_isPaused) {
            var now = (currentTime != null) ? currentTime : System.getTimer();
            var pauseDuration = now - _pauseStartTime;
            _pointStartTime += pauseDuration;
            _isPaused = false;
            _pauseStartTime = null;
        }
    }

    /**
     * Get the current dark team score.
     */
    function getScoreDark() {
        return _scoreDark;
    }

    /**
     * Get the current light team score.
     */
    function getScoreLight() {
        return _scoreLight;
    }

    /**
     * Get the current gender ratio indicator ("A" or "B").
     */
    function getCurrentGender() {
        return _currentGender;
    }

    /**
     * Get the next gender ratio indicator ("A" or "B") for the next point.
     */
    function getNextGender() {
        return _nextGender;
    }

    /**
     * Check if the game is currently paused.
     */
    function isPaused() {
        return _isPaused;
    }

    /**
     * Get the total elapsed game time in milliseconds.
     * Total time continues counting even when paused.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getTotalElapsedTime(currentTime) {
        var now = (currentTime != null) ? currentTime : System.getTimer();
        return now - _gameStartTime;
    }

    /**
     * Get the elapsed time for the current point in milliseconds.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getPointElapsedTime(currentTime) {
        var now = (currentTime != null) ? currentTime : System.getTimer();
        if (_isPaused && _pauseStartTime != null) {
            return _pauseStartTime - _pointStartTime;
        }
        return now - _pointStartTime;
    }

    /**
     * Format milliseconds as MM:SS string.
     * @param milliseconds Time in milliseconds.
     */
    function formatTime(milliseconds) {
        var minutes = milliseconds / 60000;
        var seconds = (milliseconds / 1000) % 60;
        return minutes.format("%d") + ":" + seconds.format("%02d");
    }

    /**
     * Get formatted total game time string (MM:SS).
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getFormattedTotalTime(currentTime) {
        return formatTime(getTotalElapsedTime(currentTime));
    }

    /**
     * Get formatted point time string (MM:SS).
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getFormattedPointTime(currentTime) {
        return formatTime(getPointElapsedTime(currentTime));
    }

    /**
     * Get the pause duration in milliseconds.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getPauseDuration(currentTime) {
        if (!_isPaused || _pauseStartTime == null) {
            return 0;
        }
        var now = (currentTime != null) ? currentTime : System.getTimer();
        return now - _pauseStartTime;
    }

    /**
     * Get formatted pause duration string (MM:SS).
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     */
    function getFormattedPauseDuration(currentTime) {
        return formatTime(getPauseDuration(currentTime));
    }

    /**
     * Undo the last score that was added.
     * Restores the previous point start time and recalculates gender ratio.
     * @param currentTime Optional current time in milliseconds. If null, uses System.getTimer().
     * @return true if a score was undone, false if history is empty.
     */
    function undoLastScore(currentTime) {
        if (_historyPoints.size() == 0) {
            return false;
        }
        
        // Get the last index before removing
        var lastIndex = _historyPoints.size() - 1;
        var team = _historyPoints[lastIndex];
        var prevStart = _historyPointStartTimes[lastIndex];
        
        // Now remove the last elements
        _historyPoints = _historyPoints.slice(0, lastIndex);
        _historyPointStartTimes = _historyPointStartTimes.slice(0, lastIndex);
        
        // Decrement the score
        if (team == POINT_DARK) {
            _scoreDark -= 1;
        } else {
            _scoreLight -= 1;
        }
        
        // Restore the previous point start time
        _pointStartTime = prevStart;
        setGender();
        return true;
    }

    /**
     * Set both current and next gender ratios based on ABBA pattern.
     * Pattern: A, B, B, A, A, B, B, A...
     * Points 0, 3, 4, 7, 8... = A
     * Points 1, 2, 5, 6, 9, 10... = B
     * 
     * If startingGender is set to "M" or "F", uses M/F pattern instead:
     * - If "M": M, F, F, M, M, F, F, M...
     * - If "F": F, M, M, F, F, M, M, F...
     */
    private function setGender() as Void {
        var points = _scoreLight + _scoreDark;
        
        var mod = points % 4;
        var isFirstGender = (mod == 0 || mod == 3);
        
        if (_startingGender == null) {
            if (isFirstGender) {
                _currentGender = "A";
            } else {
                _currentGender = "B";
            }
            
            var nextPoint = points + 1;
            var nextMod = nextPoint % 4;
            if (nextMod == 0 || nextMod == 3) {
                _nextGender = "A";
            } else {
                _nextGender = "B";
            }
        } else {
            if (isFirstGender) {
                _currentGender = _startingGender;
                _nextGender = _startingGender.equals("M") ? "F" : "M";
            } else {
                _currentGender = _startingGender.equals("M") ? "F" : "M";
                _nextGender = _currentGender;
            }
            
            var nextPoint = points + 1;
            var nextMod = nextPoint % 4;
            if (nextMod == 0 || nextMod == 3) {
                _nextGender = _startingGender;
            } else {
                _nextGender = _startingGender.equals("M") ? "F" : "M";
            }
        }
    }

    /**
     * Callback for position updates from GPS.
     * @param info Position.Info object containing location data.
     */
    function onPosition(info as Position.Info) as Void {
        if (_session != null && info != null && info.position != null) {
            
        }
    }

    /**
     * Save the activity recording session.
     */
    function saveSession() as Void {
        if (_session != null && _session has :stop) {
            _session.stop();
        }
        if (_session != null && _session has :save) {
            _session.save();
        }
        _session = null;
    }

    /**
     * Discard the activity recording session.
     */
    function discardSession() as Void {
        if (_session != null && _session has :stop) {
            _session.stop();
        }
        if (_session != null && _session has :discard) {
            _session.discard();
        }
        _session = null;
    }

    /**
     * Cleanup resources when the model is being destroyed.
     */
    function cleanup() as Void {
        if (Position has :enableLocationEvents) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
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
    }

}

