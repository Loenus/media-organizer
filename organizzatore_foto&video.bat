@ECHO OFF 
TITLE Organizzatore foto e video by Lorenzo

ECHO Inserisci il path della directory con le foto da organizzare
:: Input dall'utente
set /p dir="Path: "
set /p org="Volete organizzi in cartelle anno/mese? ("s" per si, "n" per no): "

:: (FAQ27-ogni "%" in un normale comando exiftool da cmd, va sostituito (in un file batch) con "%%" (=> ogni "%%" con "%%%%"))

:: i file che provengono dai social (come WhatsApp) non contengono negli exif nè la data nè il creatore.
:: però il filename contiene la data di creazione, => metto negli exif la data, presa dal nome del file
:: marchio i file provenienti da whatsapp scrivendocelo nel tag "model" (così da poterli riconoscere, poichè non hanno il tag "make")
ECHO Sistemo i file provenienti da WhatsApp...
exiftool -m -F -if "($fileextension =~ /JPG/i and not $DateTimeOriginal) or ($fileextension =~ /mp4/i and $createdate eq '0000:00:00 00:00:00')" "-alldates<${filename;$_=substr($_,0,12)} 00:00:00" "-model=WhatsApp" "%dir%" -overwrite_original

:: se ci sono dei file provenienti da whatsapp...
if %ERRORLEVEL% neq 2 (
:: Rintraccio i file con model="WhatsApp" e li rinomino solo con la data "YYYY-MM-DD_A..."
ECHO ===== Organizzo FOTO e VIDEO from WHATSAPP =====
exiftool -m -F -if "($fileextension =~ /JPG/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.jpg" -d "%%Y-%%m-%%d%%%%+uc" "%dir%"
exiftool -m -F -if "($fileextension =~ /mp4/i) and ($model =~ /WhatsApp/i)" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d%%%%+uc" "%dir%"
) else (ECHO Non ho trovato file provenienti da WhatsApp. Proseguo...)

:: aggiungo ai video (non di Whatsapp) negli exif la data del filename (senza, non ci sarebbe fuso orario corretto..)
ECHO Sistemo i file restanti ...
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model" "-alldates<filename" "%dir%" -overwrite_original

:: Rintraccio le foto con tag creatore non nullo e i video che non hanno un creatore (ovvero foto e video del cellulare o camera professionale)
:: e li rinomino con data,orario (e modello, nel caso delle foto) -> "YYYY-MM-DD HH:mm:SS.mp4" "YYYY-MM-DD HH:mm:SS MAKE.mp4"
ECHO ===== Organizzo FOTO e VIDEO from Smartphone or Camera =====
exiftool -m -F -if "($fileextension =~ /JPG/i or $fileextension =~ /JPEG/i) and $DateTimeOriginal and $make" "-filename<${DateTimeOriginal} $make.jpg" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" "%dir%"
exiftool -m -F -if "$fileextension =~ /mp4/i and not $model" "-filename<${DateTimeOriginal}.mp4" -d "%%Y-%%m-%%d %%H.%%M.%%S%%%%-c" -ext mp4 "%dir%"

if "%org%" equ "s" (
exiftool -m -F -d "%dir%"/%%Y/%%m_%%B "-directory<filemodifydate" "-directory<datetimeoriginal" "%dir%"
)
:: Sistemare: il path della directory di destinazione (quella creata) finisce nel desktop
PAUSE


:: TODO (ma anche no)
:: -foto e video whatsapp ordinate cronologicamente in base al "WA0000" numero dopo il WA
:: -togliere i warning causati dall'incapacità di exiftool di leggere i Maker Notes