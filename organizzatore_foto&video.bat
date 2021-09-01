@ECHO OFF 
TITLE media orginizer (by Loenus)

ECHO Enter the path of the directory with the files to organize
:: User Input
set /p dir="Path: "
set /p org="Do you want to organize into folders year/month? ("y" per yes, "n" per no): "

:: i file che provengono dai social (come WhatsApp) non contengono negli exif nè la data nè il creatore.
:: però il filename contiene la data di creazione, => metto negli exif la data, presa dal nome del file
:: marchio i file provenienti da whatsapp scrivendocelo nel tag "model" (così da poterli riconoscere, poichè non hanno il tag "make")
ECHO Fixing files coming from Whatsapp ...
exiftool -m -F -if "($fileextension =~ /JPG/i and not $DateTimeOriginal) or ($fileextension =~ /mp4/i and $createdate eq '0000:00:00 00:00:00')" "-alldates<${filename;$_=substr($_,0,12)} 00:00:00" "-model=WhatsApp" "%dir%" -overwrite_original

:: se ci sono dei file provenienti da whatsapp (tutti i file non hanno soddisfatto l'if precedente) ...
if %ERRORLEVEL% neq 2 (
:: Rintraccio i file con model="WhatsApp" e li rinomino solo con la data "YYYY-MM-DD_A..."
ECHO ===== PHOTOS e VIDEOs from WHATSAPP =====
exiftool -m -F -if "($fileextension =~ /JPG/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.jpg" -d "%%Y-%%m-%%d%%%%+uc" "%dir%"
exiftool -m -F -if "($fileextension =~ /mp4/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d%%%%+uc" "%dir%"
) else (ECHO I have not found any files from WhatsApp. Continue ...)

:: aggiungo ai video (non di Whatsapp) negli exif la data del filename (senza, non ci sarebbe fuso orario corretto..)
ECHO Arranging the remaining files ...
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model" "-alldates<filename" "%dir%" -overwrite_original

:: Rintraccio le foto con tag creatore non nullo e i video che non hanno un creatore (ovvero foto e video del cellulare o camera professionale)
:: e li rinomino con data,orario (e modello, nel caso delle foto) -> "YYYY-MM-DD HH:mm:SS.mp4" "YYYY-MM-DD HH:mm:SS MAKE.mp4"
ECHO ===== PHOTOS e VIDEOS from Smartphone or Camera =====
exiftool -m -F -if "($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $make" "-filename<${DateTimeOriginal} $make.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" "%dir%"
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" -ext mp4 "%dir%"

if "%org%" equ "y" (
exiftool -m -F -d "%dir%"/%%Y/%%m_%%B "-directory<filemodifydate" "-directory<datetimeoriginal" "%dir%"
)

PAUSE
