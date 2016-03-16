# Plan week 19

## SVN-update issues 


### Kijken wat er mis is

- svn update
    - Conflict door compoments.xml
    - Accepteer mine-conflict
    - “No such revision”
- cd leerlijnen
- svn commit -m “Put back server components.xml”
- svn cleanup


### Voor Maarten: kopiëren van SVN

Ik had veel werk doordat de werkdirectory later was gekopieerd dan de subversion repo. Omdat auteurs nog aan
  het editten waren tijdens het kopiëren (het is ook geen ideale situatie voor een kopie), liep de werkdirectory
  vóór op de svn repo. Dit gaf bij svn update steeds problemen (laatste versie nieuwer dan wat de repo weet,
  sommige files zijn bij commit niet bekend bij repo). Dit betekende dat ik handmatige een file heb
  toegevoegd, gecommit, weerweggehaald en dat 30x op een versie nummer okay te krijgen. Maar verderop krijg
  je dan toch problemen omdat plaatjes lokaal staan aangevinkt als deel van de repo, maar de repo weet dat niet.
  
Dit betekent dat je ook op acceptatie geen globale update kan draaien. De meeste commando's hieronder heb ik dan ook
  zo proberen te formuleren dat ze op een deel van de boom draaien. Laat me weten aks een van de dingen niet werkt.
  

### Voor Robin: svn do's en dont's

- Alleen threads.xml editten, niet de components.xml. De huidige server versie van svn-update kan anders de leerlijnen
  niet updaten. Je kan ook alleen threads.xml updaten met mijn laatste versie via
  [http://mathpluscms.tst.malmberg.nl/MathUnited/svn-update?path=/leerlijnen/threads.xml]().
  Dit werkt ook voor een sub-boom, e.g. [http://mathpluscms.tst.malmberg.nl/MathUnited/svn-update?path=/vd]() ; en
  ook voor svn-status: [http://mathpluscms.tst.malmberg.nl/MathUnited/svn-status?path=/vd]()
- Helpfiles zoals MD5 en DONE die door tools worden gemaakt en niet nodig zijn voor de repo moet je niet in subversion
  inchecken
  
  
  
### Stappen om svn boom klaar te maken

1. We gaan eerst overbodige files verwijderen. Deze maken de performance van svn-update en svn-status echt slecht.
 
2. We fixen SVN issues. Foute dirs etc. 

Deze stappen worden hieronder in detail besproken.

### Overbodige files verwijderen

We doen alle operaties als tomcat

    sudo -s -u tomcat
    cd /opt/data/mathplus
    
Eerst verwijderen we de history die niet meer nodig is. Maak eventueeel een backup!    
    
    svn update --accept theirs-full _history 
    svn rm --force _history
    svn commit _history -m "Removed _history from repo"
    rm -rf _history

Dan verwijderen we de directory `_valide_content` die abusievelijk in repo zit.
 
    svn update --accept theirs-full _valide_content 
    svn rm --force _valide_content
    svn commit _valide_content -m "Removed _valide_content from repo"
    rm -rf _valide_content
    
Na deze acties is `svn status` wat echt veel tijd kostte (minuten) voorheen al in enkele secondes klaar. Het is dus
een nuttige actie.
    
Dan de plaatjes die in root zijn terecht gekomen. Deze staan zelf niet in repo, maar thumbnail directory `mcith` wel.

    tar cvfz /tmp/plaatjes-root-repo-20150430.tgz *.jpg *.bmp *.svg *.png *.eps
    rm *.jpg *.bmp *.svg *.png *.eps
    svn update --accept theirs-full mcith
    svn rm --force mcith
    svn commit mcith -m "Removed thumbnails from root of repo"
    rm -rf mcith
      
Verwijder de ff, stacktrace, done, md5  files: overblijfselen van runs met tools direct in contente tree, niet in repo

    find . -type f -name ff  -exec rm '{}' \;
    find . -type f -name stacktrace  -exec rm '{}' \;
    find . -type f -name done  -exec rm '{}' \;
    find . -type f -name md5  -exec rm '{}' \;

Verwijder de deadjoe files, overblijfselen van locale edits van mensen direct in boom met de editor joe, niet in repo

    find . -type f -name deadjoe  -exec rm '{}' \;


### Fixen van svn issues

Robin's `components.xml` ignoreren, threads updaten
 
    svn update --accept mine-conflict leerlijnen
    svn commit leerlijnen -m "Updated leerlijnen"

Fout geplaatste plaatjes leiden tot svn update issues (niet bestaande mcith directory, lokaal)

    cd /opt/data/mathplus/hb/hb-b2/images
    svn rm --force mcith
    svn rm --force hb_feg_07_vb4_03_2.png
    svn commit -m "Image in wrong place"
    cd /opt/data/mathplus

Er staan wat lege directories in hv, niet in repo:

    rmdir hv/pre1/hv-pre115 
    rmdir hv/pre1/hv-pre16
    
Nog meer rommel van tools (dirs door tools, niet via svn (dus geen .svn))
    
    cd /opt/data/mathplus/hv/re1
    rm -rf hv-re1-test-in/
    svn update
    cd /opt/data/mathplus    

Mijn work dir was recenter dan de svn repo bij de copy (omdat er door geauteurd werd) daardoor waren
wat files out of date. We willen straks de index.xml uit repo halen, maar dat kan niet zonder tool
offline te halen, dus we laten ze even zitten. Als ze niet extern worden geëdit is dit geen probleem
(geld ook voor components.xml)

    find . -type f -name index.xml -exec svn update --accept mine-full '{}' \;

Robin's vd directory is op een of andere manier lokaal geplaatst zonder svn in sommige subdirs

    cd /opt/data/mathplus/vd/vd-b1
    rmdir vd-b1* # Negeer foutmeldingen
    svn update
    cd /op/data/mathplus
   
Ik had ook problemen met de index.xml van die directory, maar dat kan komen doordat werkdir en svn op ander
moment door kopie zijn gehaald (mijn werkboom loopt revisies voor op svn repo). Omdat dit een gegenereerde file
is zetten we die even aan de kant.

    svn revert vd/vd-b1/index.xml
    rm -f vd/vd-b1/index.xml

Hierdoor komen weer enkele foute files in de repo (nu met iname: ze zijn uppercase)
    
    find vd -type f -iname ff  -exec svn rm '{}' \;
    find vd -type f -iname stacktrace  -exec svn rm '{}' \;
    find vd -type f -iname done  -exec svn rm '{}' \;
    find vd -type f -iname md5  -exec svn rm '{}' \;
    svn commit vd -m "cleaned vd"

De directory ha-e4 heeft geen images subdir

    cd /opt/data/mathplus/ha/ha-e4
    mkdir -p images/highres
    mv ha-e41/normale\ verdeling\ leeftijd\ moeders.jpg images/highres
    rm -rf ha-e41/mcith
    svn add images
    svn commit -m "Added images subdir to ha-e4"
    cd /op/data/mathplus
    
Toevoegen van laatste versie van Robin's vd-d1 XML files (zie attachment, zet die in /tmp)
    
    cd /opt/data/mathplus/vd
    svn update
    unzip -o /tmp/vwo\ d1\ en\ threads.zip
    rm threads.xml # Die hebben we hier niet nodig en deze is identiek aan de svn versie
    svn add --force vd-d1/
    svn commit -m "Merged Robin's latest vd-d1"
            
    
    
### Genereer de files opnieuw aan

[http://mathpluscms.tst.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()

### Voor workflow

- DO NOT EDIT COMPONENTS.XML


