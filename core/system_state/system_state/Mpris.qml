import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Scope {
    id: root

    // ============================================================================
    // PROPERTIES (Public API)
    // ============================================================================

    property var currentPlayer: null
    
    // Metadata
    readonly property string title: currentPlayer ? (currentPlayer.trackTitle || "") : ""
    readonly property string artist: currentPlayer ? (currentPlayer.trackArtist || "") : ""
    readonly property string album: currentPlayer ? (currentPlayer.trackAlbum || "") : ""
    readonly property string artUrl: currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
    readonly property string identity: currentPlayer ? (currentPlayer.identity || "") : ""
    
    // Status
    readonly property bool isPlaying: currentPlayer ? (currentPlayer.playbackState === MprisPlaybackState.Playing) : false
    readonly property bool canPlay: currentPlayer ? currentPlayer.canPlay : false
    readonly property bool canPause: currentPlayer ? currentPlayer.canPause : false
    readonly property bool canGoNext: currentPlayer ? currentPlayer.canGoNext : false
    readonly property bool canGoPrevious: currentPlayer ? currentPlayer.canGoPrevious : false
    readonly property bool canSeek: currentPlayer ? currentPlayer.canSeek : false
    
    // Position & Length
    // position is updated by timer to ensure UI smoothness
    property real position: 0
    property real length: currentPlayer ? currentPlayer.length : 0

    Behavior on position {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.Linear
        }
    }
    
    // Formatting helpers
    property string positionString: formatTime(position)
    property string lengthString: formatTime(length)

    // Interaction state
    property bool isSeeking: false
    property bool userInteracting: false // Can be bound to global interaction state

    // ============================================================================
    // LOGIC
    // ============================================================================

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = Math.floor(seconds % 60);
        var pad = function(n) { return (n < 10) ? ("0" + n) : n; };
        
        if (h > 0) {
            return h + ":" + pad(m) + ":" + pad(s);
        } else {
            return m + ":" + pad(s);
        }
    }

    // ----------------------------------------------------------------------------
    // Player Selection
    // ----------------------------------------------------------------------------

    function updateCurrentPlayer() {
        var players = Mpris.players.values;
        if (players.length === 0) {
            currentPlayer = null;
            return;
        }

        // 1. Find a playing player
        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) {
                // Fix: Compare identity strings instead of object references
                // to prevent UI flickering/resets when the backend updates wrappers.
                if (!currentPlayer || currentPlayer.identity !== players[i].identity) {
                    currentPlayer = players[i];
                }
                return;
            }
        }

        // 2. If current player is still valid (paused), keep it
        if (currentPlayer) {
            for (var j = 0; j < players.length; j++) {
                if (players[j].identity === currentPlayer.identity) {
                    return;
                }
            }
        }

        // 3. Fallback to first available
        if (!currentPlayer || currentPlayer.identity !== players[0].identity) {
            currentPlayer = players[0];
        }
    }

    // Monitor players list changes
    Connections {
        target: Mpris.players
        function onValuesChanged() {
            updateCurrentPlayer();
        }
    }

    // Monitor playback state changes to switch to playing player
    Timer {
        id: playerStateMonitor
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            updateCurrentPlayer();
        }
    }

    // ----------------------------------------------------------------------------
    // Position Updates
    // ----------------------------------------------------------------------------

    // Sync position from player when not seeking
    Connections {
        target: currentPlayer
        function onPositionChanged() {
            if (!root.isSeeking && currentPlayer) {
                root.position = currentPlayer.position;
            }
        }
        function onPlaybackStateChanged() {
             updateCurrentPlayer(); // Also re-check selection on state change
             if (!root.isSeeking && currentPlayer) {
                 root.position = currentPlayer.position;
             }
        }
    }
    
    // Smooth timer for UI
    Timer {
        interval: 1000
        running: root.isPlaying && !root.isSeeking
        repeat: true
        onTriggered: {
            if (currentPlayer) {
                root.position = currentPlayer.position;
            }
        }
    }
    
    // Reset position if player changes
    onCurrentPlayerChanged: {
        if (currentPlayer) {
            if (!isSeeking) root.position = currentPlayer.position;
        } else {
            root.position = 0;
        }
    }

    // ============================================================================
    // CONTROLS
    // ============================================================================

    function playPause() {
        if (currentPlayer) currentPlayer.togglePlaying();
    }

    function play() {
        if (currentPlayer) currentPlayer.play();
    }

    function pause() {
        if (currentPlayer) currentPlayer.pause();
    }

    function stop() {
        if (currentPlayer) currentPlayer.stop();
    }

    function next() {
        if (currentPlayer) currentPlayer.next();
    }

    function previous() {
        if (currentPlayer) currentPlayer.previous();
    }

    function seek(seconds) {
        if (currentPlayer && currentPlayer.canSeek) {
            currentPlayer.position = seconds;
            root.position = seconds; // Instant UI update
        }
    }
    
    Component.onCompleted: {
        updateCurrentPlayer();
    }
}