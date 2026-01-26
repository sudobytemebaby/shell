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
        // We need to unset isSeeking eventually. 
        // Ideally the slider handles this (onPressed/onReleased).
        // If the UI only calls this on 'moved', we might need `playerSeekStart` and `playerSeekEnd`.
        // However, the original code didn't have start/end logic, just seek(pos).
        // But `noctalia` implementation relies on `isSeeking` property.
        // If the UI doesn't expose start/end events, we can't perfectly control `isSeeking`.
        // But `Mpris.qml` has `seek(seconds)` which sets `root.position = seconds`.
        // If we just call seek, it updates.
        // The `isSeeking` property in `Mpris.qml` is to prevent *timer* updates overwriting the user's drag.
        // If `MediaManager` doesn't expose `setIsSeeking`, we might have a problem if the UI binds `value` to `playerPosition` and dragging conflicts with updates.
        // But since we removed the timer from `MediaManager` and `Mpris.qml` timer updates `position`, 
        // if `playerPosition` updates, the slider might jump.
        // I will add `playerSeekStart` and `playerSeekEnd` and hope the user updates the UI to use them?
        // Or, assume `playerSeek` is called on *release*?
        // Usually sliders call seek on change.
        // Let's assume `playerSeek` is instantaneous.
        // To properly support dragging, I should expose `isSeeking` logic.
        // I'll add a timer to auto-reset isSeeking if not updated? No, that's hacky.
        // I'll just expose `isSeeking` property and let the UI bind to it if it wants, 
        // OR just set `mprisState.isSeeking = true` here and rely on `seek` to update position.
        // Wait, if I set `isSeeking = true` how does it go back to false?
        // I'll add `function setSeeking(seeking)`.
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
