pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: utils
    
    /**
     * Execute a command and handle output/errors properly
     * @param parent - Parent object (for cleanup)
     * @param command - Array of command parts ["cmd", "arg1", "arg2"]
     * @param onSuccess - Callback(stdout) on exit code 0
     * @param onError - Callback(exitCode, stderr) on non-zero exit
     * @returns Process object (can be ignored or stored)
     */
    function runCommand(parent, command, onSuccess, onError) {
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; import QtQuick; Process {}',
            parent,
            "DynamicProcess"
        )
        if (!proc) {
          console.error("[ProcessUtils] Failed to create Process object!")
          return null
        }
        
        proc.command = command
        
        var stdoutData = ""
        var stderrData = ""
        
        // Setup stdout parser
        var stdoutParser = Qt.createQmlObject(
            'import Quickshell.Io; SplitParser {}',
            proc,
            "StdoutParser"
        )
        stdoutParser.onRead.connect(data => {
            if (data) stdoutData += data
        })
        proc.stdout = stdoutParser
        
        // Setup stderr parser
        var stderrParser = Qt.createQmlObject(
            'import Quickshell.Io; SplitParser {}',
            proc,
            "StderrParser"
        )
        stderrParser.onRead.connect(data => {
            if (data) stderrData += data
        })
        proc.stderr = stderrParser
        
        // Handle exit
        proc.exited.connect(code => {
            try {
                if (code === 0) {
                    if (onSuccess) onSuccess(stdoutData.trim())
                } else {
                    var errorMsg = stderrData.trim() || "Command failed with code " + code
                    console.error("[ProcessUtils]", command[0], "failed:", errorMsg)
                    if (onError) onError(code, errorMsg)
                }
            } catch (e) {
                console.error("[ProcessUtils] Callback error:", e)
            } finally {
                proc.destroy()
            }
        })
        
        proc.running = true
        console.log("[ProcessUtils] Process started, running:", proc.running, "command:", command.join(" "))
        return proc
    }
    
    /**
     * Fire-and-forget command execution
     */
    function runCommandAsync(parent, command) {
        runCommand(parent, command, null, null)
    }
}
