import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../../core" as Core

Scope {
    id: manager
    
    // ========== MEDIA PLAYER STATE (Public API) ==========
    property bool playerActive: false
    property bool playerPlaying: false
    property string playerTitle: ""
    property string playerArtist: ""
    property string playerName: ""
    property real playerPosition: 0.0  // Current position in seconds
    property real playerLength: 0.0     // Total length in seconds
    
    // Track if control center is visible (for position updates)
    property bool controlCenterVisible: false
    
    // ========== NATIVE MPRIS INTEGRATION ==========
    
    // Get first available player (or null if none)
    readonly property var activePlayer: Mpris.players.values.length > 0 
        ? Mpris.players.values[0] 
        : null
    
    // Automatically update state when player changes
    Connections {
        target: manager
        function onActivePlayerChanged() {
            updatePlayerState()
        }
    }
    
    // Watch for player property changes
    Connections {
        target: manager.activePlayer
        enabled: manager.activePlayer !== null
        
        function onPlaybackStateChanged() {
            updatePlayerState()
        }
        
        function onMetadataChanged() {
            updatePlayerState()
        }
        
        function onPositionChanged() {
            // Update position from player (already in seconds)
            if (manager.activePlayer && manager.activePlayer.position !== undefined) {
                var newPosition = manager.activePlayer.position
                if (!isNaN(newPosition) && newPosition >= 0) {
                    manager.playerPosition = newPosition
                }
            }
        }
    }
    
    // Poll position when playing
    // Updates more frequently when control center is visible for smooth progress bars
    Timer {
        interval: manager.controlCenterVisible ? 500 : 2000
        running: manager.playerPlaying && manager.activePlayer !== null
        repeat: true
        onTriggered: {
            if (manager.activePlayer && manager.activePlayer.position !== undefined) {
                var newPosition = manager.activePlayer.position
                if (!isNaN(newPosition) && newPosition >= 0) {
                    manager.playerPosition = newPosition
                }
            }
        }
    }
    
    // Update all player state from active player
    function updatePlayerState() {
        if (manager.activePlayer === null) {
            manager.playerActive = false
            manager.playerPlaying = false
            manager.playerTitle = ""
            manager.playerArtist = ""
            manager.playerName = ""
            manager.playerPosition = 0.0
            manager.playerLength = 0.0
            return
        }
        
        var player = manager.activePlayer
        manager.playerActive = true
        manager.playerPlaying = (player.playbackState === MprisPlaybackState.Playing)
        
        // Use player's direct properties (these have extra guards against bad metadata)
        manager.playerTitle = player.trackTitle || ""
        manager.playerArtist = player.trackArtist || ""
        manager.playerName = player.identity || ""
        
        // Position and length from player
        // Both position and length are already in seconds from Quickshell
        var position = player.position || 0
        var length = player.length || 0
        
        // Validate values before assigning
        manager.playerPosition = (!isNaN(position) && position >= 0) ? position : 0.0
        manager.playerLength = (!isNaN(length) && length > 0) ? length : 0.0
    }
    
    // Initialize on startup
    Component.onCompleted: {
        updatePlayerState()
    }
    
    // ========== MEDIA PLAYER CONTROLS ==========
    
    function playerPlayPause() {
        if (manager.activePlayer) {
            manager.activePlayer.togglePlaying()
        }
    }
    
    function playerNext() {
        if (manager.activePlayer) {
            manager.activePlayer.next()
        }
    }
    
    function playerPrevious() {
        if (manager.activePlayer) {
            manager.activePlayer.previous()
        }
    }
    
    function playerStop() {
        if (manager.activePlayer) {
            manager.activePlayer.stop()
        }
    }
    
    function playerSeek(position) {
        if (manager.activePlayer) {
            // Update UI immediately for responsive feel
            manager.playerPosition = position
            // Set position directly (already in seconds)
            manager.activePlayer.position = position
        }
    }
    
    function playerSeekRelative(offset) {
        if (manager.activePlayer) {
            // Seek relative (offset already in seconds)
            manager.activePlayer.seek(offset)
        }
    }
    
    // Helper function to format time (seconds -> MM:SS)
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00"
        
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
