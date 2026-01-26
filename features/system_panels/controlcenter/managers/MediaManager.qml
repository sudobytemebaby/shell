import QtQuick
import Quickshell

Scope {
    id: manager
    
    // Shared state passed from parent
    required property var mprisState
    
    // Track if control center is visible (can be used for optimization if needed)
    property bool controlCenterVisible: false
    
    // ========== MEDIA PLAYER STATE (Public API) ==========
    // Aliases to the shared state
    
    readonly property bool playerActive: mprisState.currentPlayer !== null
    readonly property bool playerPlaying: mprisState.isPlaying
    readonly property string playerTitle: mprisState.title
    readonly property string playerArtist: mprisState.artist
    readonly property string playerArtUrl: mprisState.artUrl
    readonly property string playerName: mprisState.identity
    
    // Position & Length
    readonly property real playerPosition: mprisState.position
    readonly property real playerLength: mprisState.length
    
    // ========== MEDIA PLAYER CONTROLS ==========
    
    function playerPlayPause() {
        mprisState.playPause()
    }
    
    function playerNext() {
        mprisState.next()
    }
    
    function playerPrevious() {
        mprisState.previous()
    }
    
    function playerStop() {
        mprisState.stop()
    }
    
    function playerSeek(position) {
        // Set isSeeking on the shared state to prevent updates while dragging
        mprisState.isSeeking = true
        mprisState.seek(position)
    }
    
    function playerSeekRelative(offset) {
       // Not implemented in Mpris.qml but easy to add or just do:
       if (mprisState.currentPlayer) mprisState.currentPlayer.position += offset
    }

    // Helper to allow UI to set seeking state
    function setSeeking(seeking) {
        mprisState.isSeeking = seeking
    }

    // Format helper (kept for compatibility)
    function formatTime(seconds) {
        return mprisState.formatTime(seconds)
    }
}
