import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// ============================================================================
// LOCK CONTEXT
// Manages PAM authentication and state
// Handles password input, authentication flow, and error messages
// ============================================================================

Scope {
  id: root

  // ============================================================================
  // SIGNALS
  // ============================================================================

  signal unlocked()
  signal failed()

  // ============================================================================
  // PUBLIC PROPERTIES
  // ============================================================================

  property string currentText: ""          // Current password text
  property bool waitingForPassword: false  // PAM waiting for response
  property bool unlockInProgress: false    // Authentication in progress
  property bool showFailure: false         // Show error state
  property bool showInfo: false            // Show info message
  property string errorMessage: ""         // Error message text
  property string infoMessage: ""          // Info message text

  readonly property bool pamAvailable: typeof PamContext !== "undefined"

  // ============================================================================
  // TEXT CHANGE HANDLER
  // ============================================================================

  onCurrentTextChanged: {
    if (currentText !== "") {
      // Clear any visible messages when user starts typing
      showInfo = false
      infoMessage = ""
      showFailure = false
      errorMessage = ""
    }
  }

  // ============================================================================
  // UNLOCK FUNCTION
  // ============================================================================

  function tryUnlock() {
    if (!pamAvailable) {
      errorMessage = "PAM not available"
      showFailure = true
      return
    }

    // Respond to PAM if it's waiting for password
    if (waitingForPassword) {
      pam.respond(currentText)
      waitingForPassword = false
      showInfo = false
      return
    }

    // Prevent duplicate unlock attempts
    if (root.unlockInProgress) {
      return
    }

    // Start authentication
    root.unlockInProgress = true
    errorMessage = ""
    showFailure = false
    pam.start()
  }

  // ============================================================================
  // PAM CONTEXT
  // ============================================================================

  PamContext {
    id: pam
    config: "login"
    user: Quickshell.env("USER") || ""

    onPamMessage: {
      if (messageIsError) {
        errorMessage = message
      } else {
        infoMessage = message
      }

      if (this.responseRequired) {
        if (root.currentText !== "") {
          // Auto-respond if we already have text
          this.respond(root.currentText)
        } else {
          // Wait for user input
          root.waitingForPassword = true
          showFailure = false
          infoMessage = "Enter password"
          showInfo = true
        }
      } else if (messageIsError) {
        showInfo = false
        showFailure = true
      } else {
        showFailure = false
        showInfo = true
      }
    }

    onCompleted: result => {
      if (result === PamResult.Success) {
        root.unlocked()
      } else {
        root.currentText = ""
        errorMessage = "Authentication failed"
        showFailure = true
        root.failed()
      }

      root.unlockInProgress = false
    }

    onError: {
      errorMessage = message || "Authentication error"
      showFailure = true
      root.unlockInProgress = false
      root.failed()
    }
  }
}
