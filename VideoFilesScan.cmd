@echo off
chcp 65001
setlocal EnableExtensions DisableDelayedExpansion
for /r %%a in (*.mkv *.mp4 *.avi *.mov) do (
    echo ###
    echo Processing "%%a"
    if /i not "%%~xa" == ".mkv" (
        mkvmerge.exe -o "%%~pna.mkv" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%%~a"
        if errorlevel 1 (
            echo Warnings/errors generated during remuxing, original file not deleted
            mkvmerge.exe -i --ui-language en "%%a">>errors.txt
            del "%%~pna.mkv"
        ) else (
            echo Deleting old file
            del "%%~a"
        )
    ) else (
        call :mkvmerge.exeinfoloop "%%a"
    )
)
cmd /k

:mkvmerge.exeinfoloop
setlocal EnableExtensions EnableDelayedExpansion
for /f "delims=" %%l in ('mkvmerge.exe -i "%~1" --ui-language en') do (
    for /f "tokens=1,4 delims=:( " %%t in ("%%l") do (
        if /i "%%u" == "audio" (
            if not defined audiotracks (
                set /a "audiotracks=1"
            ) else (
                set /a "audiotracks+=1"
            )
            if !audiotracks! GTR 1 (
                mkvmerge.exe -i "%~1" --ui-language en >> extratracks.cmd
            )
        )
        
        if /i "%%u" == "subtitles" (
            echo ###
            echo "%~1" has subtitles
            mkvmerge.exe -o "%~dpn1.nosubs%~x1" -S -M -T -B --no-global-tags --no-chapters --ui-language en "%~1"
            if errorlevel 1 (
                echo ###
                echo Warnings/errors generated during remuxing, original file not deleted, check errors.txt
                mkvmerge.exe -i --ui-language en "%~1">>errors.txt
                del "%~dpn1.nosubs%~x1"
            ) else (
				echo Deleting old file
                del /f "%~1"
				echo Renaming new file
				ren "%~dpn1.nosubs%~x1" "%~nx1"
            )
            goto :eof
        )
        if /i "%%t" == "Attachment" set propedit=1
        if /i "%%t" == "Global" set propedit=1
        if /i "%%t" == "Chapter" set propedit=1
    )
    if defined propedit (
        echo ###
        echo "%~1" has extras
        mkvpropedit.exe "%~f1" --delete-attachment mime-type:image/jpeg --chapters "" --tags all:
        mkvpropedit.exe "%~f1" --delete-attachment mime-type:application/x-truetype-font
        mkvpropedit.exe "%~f1" --delete-attachment mime-type:application/vnd.ms-opentype
        goto :eof       
    )
)
endlocal
goto :eof