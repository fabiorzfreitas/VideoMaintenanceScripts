@echo off
chcp 65001
for /r %%g in (*.mkv) do (
    for /f %%b in ('mkvmerge -i "%%g" ^| find /c /i "bytes"') do (
	    if [%%b]==[0] (
            for /f %%c in ('mkvmerge -i "%%g" ^| findstr /R /C:"[0-9s]: [0-9]" ^| find /c /v ""') do (
			    if [%%c]==[0] (
			        echo "%%g" has no extras
				) else (
				    echo "%%g"
					mkvpropedit "%%~fg" --tags all: --chapters ""
					)
		    )
		) else (
            echo "%%g"
            mkvpropedit "%%~fg" --delete-attachment mime-type:image/jpeg --chapters "" --tags all:
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/x-truetype-font
            mkvpropedit "%%~fg" --delete-attachment mime-type:application/vnd.ms-opentype
	        )
	)
)
cmd /k