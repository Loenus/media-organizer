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
exiftool -m -F -if "($fileextension =~ /JPG/i and not $DateTimeOriginal and not $filename=~/^Screenshot_/i) or ($fileextension =~ /mp4/i and $createdate eq '0000:00:00 00:00:00')" "-alldates<${filename;$_=substr($_,0,12)} 00:00:00" "-model=WhatsApp" "%dir%" -overwrite_original

:: "-model<${filename;m/\.([^\.]+)\./;$_=$1}" salva l'ultima parte del nome dello screenshot (che indica l'app in cui è stato fatto lo screenshot) nel exifdata 'model'
:: alternativa= "-model<${filename;m/\.(.*)\./;$_=$1}" per un nome più specifico
ECHO Fixing Screenshots...
exiftool -m -F -if "$fileextension =~ /JPG/i and not $DateTimeOriginal and $filename=~/^Screenshot_/i" "-alldates<${filename;$_=substr($_,0,30)} 00:00:00" "-model< " "%dir%" -overwrite_original
exiftool -m -F -if "$fileextension =~ /JPG/i and not $DateTimeOriginal and $filename=~/^Screenshot_/i" "-model<${filename;m/\.([^\.]+)\./;$_=$1}" "%dir%" -overwrite_original
:: la prima linea è nel caso la regex della seconda linea non trova niente (ad esempio: screenshot al lockscreen), allora inizializza comunque il tag model vuoto.

:: se ci sono dei file provenienti da whatsapp...
if %ERRORLEVEL% neq 2 (
:: Rintraccio i file con model="WhatsApp" e li rinomino solo con la data "YYYY-MM-DD_A..."
ECHO ===== PHOTOS e VIDEOs from WHATSAPP =====
exiftool -m -F -if "($fileextension =~ /JPG/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.jpg" -d "%%Y-%%m-%%d WA%%%%+uc" "%dir%"
exiftool -m -F -if "($fileextension =~ /mp4/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d WA%%%%+uc" "%dir%"
) else (ECHO I have not found any files from WhatsApp. Continue ...)

:: aggiungo ai video (non di Whatsapp) negli exif la data del filename (senza, non ci sarebbe fuso orario corretto..)
ECHO Arranging the remaining files ...
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model" "-alldates<filename" "%dir%" -overwrite_original
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model and $filename=~/^Screenrecorder/i" "-alldates<filename" "%dir%" -overwrite_original



ECHO START EDITING ALL FILES NAMES

:: Rintraccio le foto con tag creatore non nullo e i video che non hanno un creatore (ovvero foto e video del cellulare o camera professionale)
:: e li rinomino con data,orario (e modello, nel caso delle foto) -> "YYYY-MM-DD HH:mm:SS.mp4" "YYYY-MM-DD HH:mm:SS MAKE.mp4"
ECHO ===== PHOTOS from Smartphone or Camera =====
exiftool -m -F -if "($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $make and not $DeviceManufacturer " "-filename<${DateTimeOriginal} $make.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" "%dir%" 
exiftool -m -F -if "($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $make and $DeviceManufacturer " "-filename<${DateTimeOriginal} $make.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S MVIMG%%%%-c" "%dir%"
:: Motion Photos/Pictures hanno come $DeviceManufacturer "Google" perché sono fatte con la fotocamera di google.
:: Per mantenere traccia della differenza tra IMG normali e MVIMG (motion photos), ho distinto i due casi nelle prime due righe. MVIMG rimane nel nome. Prima riga: foto normali, seconda riga: MVIMG photos.

ECHO ===== VIDEOS from Smartphone or Camera =====
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model and not $filename=~/^Screenrecorder/i" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" -ext mp4 "%dir%"

ECHO ===== ScreenShots and ScreenRecorders =====
exiftool -m -F -if "$model and ($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $filename=~/^Screenshot_/i" "-filename<ScreenShot ${DateTimeOriginal} $model.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" "%dir%"
exiftool -m -F -if "not $model and ($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $filename=~/^Screenshot_/i" "-filename<ScreenShot ${DateTimeOriginal}.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" "%dir%"
exiftool -m -F -if "not $model and $fileextension =~ /mp4/i and $filename=~/^Screenrecorder/i" "-filename<ScreenRecorder ${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" -ext mp4 "%dir%"



if "%org%" equ "y" (
exiftool -m -F -d "%dir%"/%%Y/%%m_%%B "-directory<filemodifydate" "-directory<datetimeoriginal" "%dir%"
)

PAUSE
