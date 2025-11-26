using Toybox.System;

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
 */
class GameModel {

    private const POINT_DARK = 0;
    private const POINT_LIGHT = 1;

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

    function initialize() {
        var now = System.getTimer();
        _gameStartTime = now;
        _pointStartTime = now;
        _scoreDark = 0;
        _scoreLight = 0;
        _isPaused = false;
        _pauseStartTime = null;
        setGender();
        _historyPoints = [];
        _historyPointStartTimes = [];
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
            // Push history before incrementing
            _historyPoints.add(POINT_LIGHT);
            _historyPointStartTimes.add(_pointStartTime);
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
     */
    private function setGender() as Void {
        var points = _scoreLight + _scoreDark;
        
        var mod = points % 4;
        if (mod == 1 || mod == 2) {
            _currentGender = "B";
        } else {
            _currentGender = "A";
        }
        
        var nextPoint = points + 1;
        var nextMod = nextPoint % 4;
        if (nextMod == 1 || nextMod == 2) {
            _nextGender = "B";
        } else {
            _nextGender = "A";
        }
    }

}

