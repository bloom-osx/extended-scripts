#!/usr/bin/osascript

on run argv
    if (count of argv) < 1 then
        display alert "Error" message "Missing application path argument." as critical
        return
    end if

    set appPath to item 1 of argv
    set appFile to POSIX file appPath
    set appInfo to info for appFile
    set appName to name of appInfo
    set appNameClean to text 1 thru -5 of appName -- remove ".app"
    set dmgBaseName to appNameClean
    set saveFolder to (do shell script "dirname " & quoted form of appPath)
    set dmgPath to saveFolder & "/" & dmgBaseName & ".dmg"

    -- Check if DMG already exists
    if (do shell script "test -e " & quoted form of dmgPath & "; echo $?") is "0" then
        display alert "DMG already exists" message "The DMG file '" & dmgBaseName & ".dmg' already exists in the target folder." as critical
        return
    end if

    set tempDmgPath to saveFolder & "/" & dmgBaseName & "-temp.dmg"
    set volumeName to appNameClean

    try
        -- Create temp DMG
        do shell script "hdiutil create -size 300m -fs HFS+ -volname " & quoted form of volumeName & " " & quoted form of tempDmgPath

        -- Attach temp DMG
        do shell script "hdiutil attach " & quoted form of tempDmgPath & " -nobrowse"
        delay 2

        set volumePath to "/Volumes/" & volumeName

        -- Copy app
        do shell script "ditto " & quoted form of appPath & " " & quoted form of (volumePath & "/" & appName)

        -- Symlink Applications
        do shell script "ln -s /Applications " & quoted form of (volumePath & "/Applications")
        delay 2

        -- Finder window setup
        tell application "Finder"
            tell disk volumeName
                open
                delay 2

                set current view of container window to icon view
                set toolbar visible of container window to false
                set statusbar visible of container window to false
                set bounds of container window to {100, 100, 600, 400}

                set viewOptions to icon view options of container window
                set arrangement of viewOptions to not arranged
                set icon size of viewOptions to 72

                update without registering applications
                delay 2

                try
                    set position of item appName to {150, 116}
                end try

                try
                    set position of item "Applications" to {350, 116}
                end try

                update without registering applications
                delay 1

                close
            end tell
        end tell

        delay 1
        do shell script "hdiutil detach " & quoted form of volumePath
        delay 1

        -- Convert to compressed DMG
        do shell script "hdiutil convert " & quoted form of tempDmgPath & " -format UDZO -o " & quoted form of dmgPath
        do shell script "rm " & quoted form of tempDmgPath

        display alert "DMG Created Successfully" message "File: " & dmgBaseName & ".dmg" as informational

    on error errMsg number errNum
        try
            do shell script "hdiutil detach '/Volumes/" & volumeName & "' 2>/dev/null || true"
            do shell script "rm " & quoted form of tempDmgPath & " 2>/dev/null || true"
        end try

        display alert "Failed to create DMG" message "Error: " & errMsg & return & "Error code: " & errNum as critical
    end try
end run
