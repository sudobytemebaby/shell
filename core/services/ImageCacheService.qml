pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../helpers/sha256.js" as Checksum

Singleton {
  id: root

  // ============================================================================
  // PUBLIC PROPERTIES
  // ============================================================================

  property bool imageMagickAvailable: false
  property bool initialized: false

  // Cache directory
  readonly property string cacheDir: {
    var homeDir = Quickshell.env("HOME")
    return homeDir + "/.cache/quickshell/image-cache/"
  }

  readonly property string thumbnailDir: cacheDir + "thumbnails/"

  // ============================================================================
  // INTERNAL STATE
  // ============================================================================

  property var pendingRequests: ({})
  property var fallbackQueue: []
  property bool fallbackProcessing: false
  readonly property int maxFallbackQueueSize: 50

  // ============================================================================
  // SIGNALS
  // ============================================================================

  signal cacheHit(string cacheKey, string cachedPath)
  signal cacheMiss(string cacheKey)
  signal processingComplete(string cacheKey, string cachedPath)
  signal processingFailed(string cacheKey, string error)

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  function init() {
    console.log("[ImageCacheService] Initializing...")
    createDirectories()
    cleanupOldCache()
    checkMagickProcess.running = true
  }

  function createDirectories() {
    Quickshell.execDetached(["mkdir", "-p", thumbnailDir])
  }

  function cleanupOldCache() {
    // Delete cache files older than 30 days
    Quickshell.execDetached(["find", thumbnailDir, "-type", "f", "-mtime", "+30", "-delete"])
    console.log("[ImageCacheService] Cleanup triggered for files older than 30 days")
  }

  // ============================================================================
  // CHECK FOR IMAGEMAGICK
  // ============================================================================

  Process {
    id: checkMagickProcess
    command: ["sh", "-c", "command -v magick >/dev/null 2>&1 && echo 'available' || echo 'missing'"]

    stdout: SplitParser {
      onRead: data => {
        if (!data) return

        var status = data.trim()
        if (status === "available") {
          root.imageMagickAvailable = true
          console.log("[ImageCacheService] ImageMagick detected")
        } else {
          root.imageMagickAvailable = false
          console.log("[ImageCacheService] ImageMagick not found, using Qt fallback")
        }

        root.initialized = true
      }
    }
  }

  // ============================================================================
  // PUBLIC API: GET THUMBNAIL (384x384)
  // ============================================================================

  function getThumbnail(sourcePath, callback) {
    if (!sourcePath || sourcePath === "") {
      callback("", false)
      return
    }

    getMtime(sourcePath, function(mtime) {
      const cacheKey = generateThumbnailKey(sourcePath, mtime)
      const cachedPath = thumbnailDir + cacheKey + ".png"

      processRequest(cacheKey, cachedPath, sourcePath, callback, function() {
        if (imageMagickAvailable) {
          startThumbnailProcessing(sourcePath, cachedPath, cacheKey)
        } else {
          queueFallbackProcessing(sourcePath, cachedPath, cacheKey, 384)
        }
      })
    })
  }

  // ============================================================================
  // CACHE KEY GENERATION
  // ============================================================================

  function generateThumbnailKey(sourcePath, mtime) {
    const keyString = sourcePath + "@384x384@" + (mtime || "unknown")
    return Checksum.sha256(keyString)
  }

  // ============================================================================
  // REQUEST PROCESSING (WITH COALESCING)
  // ============================================================================

  function processRequest(cacheKey, cachedPath, sourcePath, callback, processFn) {
    // Check if already processing this request
    if (pendingRequests[cacheKey]) {
      pendingRequests[cacheKey].callbacks.push(callback)
      console.log("[ImageCacheService] Coalescing request for:", cacheKey)
      return
    }

    // Check cache first
    checkFileExists(cachedPath, function(exists) {
      if (exists) {
        console.log("[ImageCacheService] Cache hit:", cachedPath)
        callback(cachedPath, true)
        cacheHit(cacheKey, cachedPath)
        return
      }

      // Re-check pendingRequests (race condition fix)
      if (pendingRequests[cacheKey]) {
        pendingRequests[cacheKey].callbacks.push(callback)
        return
      }

      // Start new processing
      console.log("[ImageCacheService] Cache miss, processing:", sourcePath)
      cacheMiss(cacheKey)
      pendingRequests[cacheKey] = {
        callbacks: [callback],
        sourcePath: sourcePath
      }

      processFn()
    })
  }

  function notifyCallbacks(cacheKey, path, success) {
    const request = pendingRequests[cacheKey]
    if (request) {
      request.callbacks.forEach(function(cb) {
        cb(path, success)
      })
      delete pendingRequests[cacheKey]
    }

    if (success) {
      processingComplete(cacheKey, path)
    } else {
      processingFailed(cacheKey, "Processing failed")
    }
  }

  // ============================================================================
  // IMAGEMAGICK PROCESSING: THUMBNAIL
  // ============================================================================

  function startThumbnailProcessing(sourcePath, outputPath, cacheKey) {
    const srcEsc = sourcePath.replace(/'/g, "'\\''")
    const dstEsc = outputPath.replace(/'/g, "'\\''")

    // Use Lanczos filter for high-quality downscaling, subtle unsharp mask, and PNG for lossless output
    const command = `magick '${srcEsc}' -auto-orient -filter Lanczos -resize '384x384^' -gravity center -extent 384x384 -unsharp 0x0.5 '${dstEsc}'`

    runProcess(command, cacheKey, outputPath, sourcePath)
  }

  // ============================================================================
  // GENERIC PROCESS RUNNER
  // ============================================================================

  function runProcess(command, cacheKey, outputPath, sourcePath) {
    const processString = `
      import QtQuick
      import Quickshell.Io
      Process {
        property string cacheKey: ""
        property string cachedPath: ""
        command: ["sh", "-c", ""]
        stdout: StdioCollector {}
        stderr: StdioCollector {}
      }
    `

    try {
      const processObj = Qt.createQmlObject(processString, root, "ImageProcess_" + cacheKey)
      processObj.cacheKey = cacheKey
      processObj.cachedPath = outputPath
      processObj.command = ["sh", "-c", command]

      processObj.exited.connect(function(exitCode) {
        if (exitCode !== 0) {
          const stderrText = processObj.stderr.text || ""
          console.error("[ImageCacheService] Processing failed:", stderrText)
          notifyCallbacks(cacheKey, sourcePath, false)
        } else {
          console.log("[ImageCacheService] Processing complete:", outputPath)
          notifyCallbacks(cacheKey, outputPath, true)
        }

        processObj.destroy()
      })

      processObj.running = true
    } catch (e) {
      console.error("[ImageCacheService] Failed to create process:", e)
      notifyCallbacks(cacheKey, sourcePath, false)
    }
  }

  // ============================================================================
  // QT FALLBACK RENDERER
  // ============================================================================

  PanelWindow {
    id: fallbackRenderer
    visible: false
    width: 1
    height: 1

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"
    mask: Region {}

    Image {
      id: fallbackImage
      property string cacheKey: ""
      property string destPath: ""
      property int targetSize: 384

      width: targetSize
      height: targetSize
      visible: true
      cache: false
      asynchronous: true
      fillMode: Image.PreserveAspectCrop
      mipmap: true
      antialiasing: true

      onStatusChanged: {
        if (!cacheKey) return

        if (status === Image.Ready) {
          grabToImage(function(result) {
            result.saveToFile(destPath)
            console.log("[ImageCacheService] Qt fallback complete:", destPath)
            notifyCallbacks(cacheKey, destPath, true)

            // Clear for next image
            cacheKey = ""
            destPath = ""
            source = ""

            // Process next in queue
            Qt.callLater(processNextFallback)
          })
        } else if (status === Image.Error) {
          console.error("[ImageCacheService] Qt fallback failed for:", source)
          const request = root.pendingRequests[cacheKey]
          notifyCallbacks(cacheKey, request ? request.sourcePath : "", false)

          // Clear for next image
          cacheKey = ""
          destPath = ""
          source = ""

          // Process next in queue
          Qt.callLater(processNextFallback)
        }
      }
    }
  }

  function queueFallbackProcessing(sourcePath, destPath, cacheKey, size) {
    // Prevent unbounded queue growth
    if (fallbackQueue.length >= maxFallbackQueueSize) {
      console.warn("[ImageCacheService] Fallback queue full, dropping oldest request")
      fallbackQueue.shift()
    }

    fallbackQueue.push({
      sourcePath: sourcePath,
      destPath: destPath,
      cacheKey: cacheKey,
      size: size
    })

    if (!fallbackProcessing) {
      Qt.callLater(processNextFallback)
    }
  }

  function processNextFallback() {
    if (fallbackQueue.length === 0) {
      fallbackProcessing = false
      return
    }

    fallbackProcessing = true
    const item = fallbackQueue.shift()

    fallbackRenderer.fallbackImage.cacheKey = item.cacheKey
    fallbackRenderer.fallbackImage.destPath = item.destPath
    fallbackRenderer.fallbackImage.targetSize = item.size
    fallbackRenderer.fallbackImage.width = item.size
    fallbackRenderer.fallbackImage.height = item.size
    fallbackRenderer.fallbackImage.source = "file://" + item.sourcePath
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  function getMtime(filePath, callback) {
    const command = `stat -c %Y '${filePath.replace(/'/g, "'\\''")}' 2>/dev/null || echo '0'`

    const processString = `
      import QtQuick
      import Quickshell.Io
      Process {
        command: ["sh", "-c", ""]
        stdout: StdioCollector {}
      }
    `

    try {
      const processObj = Qt.createQmlObject(processString, root, "MtimeProcess_" + Math.random())
      processObj.command = ["sh", "-c", command]

      processObj.exited.connect(function(exitCode) {
        const mtime = processObj.stdout.text.trim()
        callback(mtime)
        processObj.destroy()
      })

      processObj.running = true
    } catch (e) {
      console.error("[ImageCacheService] Failed to get mtime:", e)
      callback("0")
    }
  }

  function checkFileExists(filePath, callback) {
    const command = `test -f '${filePath.replace(/'/g, "'\\''")}' && echo 'exists' || echo 'missing'`

    const processString = `
      import QtQuick
      import Quickshell.Io
      Process {
        command: ["sh", "-c", ""]
        stdout: StdioCollector {}
      }
    `

    try {
      const processObj = Qt.createQmlObject(processString, root, "ExistsProcess_" + Math.random())
      processObj.command = ["sh", "-c", command]

      processObj.exited.connect(function(exitCode) {
        const result = processObj.stdout.text.trim()
        callback(result === "exists")
        processObj.destroy()
      })

      processObj.running = true
    } catch (e) {
      console.error("[ImageCacheService] Failed to check file:", e)
      callback(false)
    }
  }

  // ============================================================================
  // AUTO-INITIALIZATION
  // ============================================================================

  Component.onCompleted: {
    init()
  }
}
