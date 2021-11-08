# Media Organizer
Organizza foto e video.  
In questi ultimi 2-3 giorni ho scritto questo programma (partendo da zero conoscenze di batch e di exiftool) per un esigenza personale: organizzare le foto attraverso il filename e la creazione, in automatico, di cartelle anno/mese

## Come funziona
All'avvio del programma vi chiederà il **path** (*assoluto*, o *relativo* rispetto a dove avete scaricato il programma) dove si trovano i media da organizzare.
A quel punto vi chiederà se volete anche che crei delle **cartelle** per gli anni e sotto cartelle per i mesi: "s" se lo volete, altrimenti "n" per organizzare i media solo rinominandoli.  
Lasciatelo correre (potrebbe volerci un pò perchè deve iterare più volte per tutti i file. Molto indicativamente: per 500 files è circa un minuto), e una volta terminato vi chiederà di premere un pulsante per chiudere la finestra del programma, ma prima di ciò potrete curiosare le stampe a schermo; tutto qua.  

>Solitamente i file provenienti dai social (come Whatsapp o Telegram) contengono pochissime informazioni exif: dai miei test, non posseggono neanche la data di creazione, che è invece scritta soltanto nel filename.  
>Questo programma non solo rinomina tutti i file, ma inserisce la data di creazione all'interno degli exif dei file che non hanno questa informazione, a partire dal filename.  
>PS: Nel filename delle foto di Whatsapp vi è contenuta solo la data, non l'orario. Perciò ogni file del medesimo giorno proveniente da Whatsapp, sarà stata scattata alle 00:00:00, con l'immediata conseguenza che l'ordine (all'interno della stessa giornata) non sarà corretto e i files verranno distinti in base a lettere inserite successivamente alla data (es: "data", "data_b", "stessa-data_c", "data-successiva").
>Per verificare la data in un singolo FILE.EXT: ``` exiftool -alldates FILE.EXT ```  
>(oppure DIR al posto del file, per sapere la data di ogni file in una particolare directory. ".": directory corrente)

## Test
Sistema Operativo: Windows10.  
Files provenienti da WhatsApp, Telegram, fotocamera nativa Xiaomi(Redmi, android) e fotocamera Sony ILCE.

>Se nell'usare il programma vedete una serie di "Warning", non temete.  
Sostianzialmente è dovuto al fatto che ogni file ha un particolare blocco di informazioni exif chiamato MakerNotes.  
Come è intuibile dal nome, sono informazioni proprietarie del produttore, che quindi non ne divulga la struttura.  
Exiftool, a differenza di altri programmi (ad esempio Photoshop), avverte quando non è in grado di leggere questi blocchi dati, ed è costretto a copiarli per intero senza saperne la struttura. Ma banalmente, anche Photoshop fa questo lavoro, senza però avvertirvi. Vi rimando alle FAQ della documentazione di exiftool.  
>esempio: Xiaomi dà questi tipi di warnings, mentre sony no. Sono facilmente leggibili con un comando da cmd su Windows:
``` exiftool -G -U -a GILE.jpg | findstr MakerNotes ```
