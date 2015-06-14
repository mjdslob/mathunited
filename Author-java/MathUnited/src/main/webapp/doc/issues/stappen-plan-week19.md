# Stappenplan SVN

Tenzij anders aangegeven door Maarten. Eerst te testen op acceptatie, dan herhalen op productie tenzij anders aangegeven.

1. Kopieer prod > acc. **Kopieer eerst de werkdir en dan pas de repo, zodat dingen die in werkdir staan nooit vooruitlopen in de tijd tov repo.** Deze stap alleen op acceptatie.
2. Deploy laatste WAR, zodat deel-updates mogelijk worden.
3. **[Robin]** Test moment. Controller dat je nog naar edit pagina kan surfen van willekeurige pagina.
3. We doen alle operaties als tomcat 

    	sudo -s -u tomcat
    	cd /opt/data/mathplus

4. Eerst verwijderen we de history die niet meer nodig is. Maak eventueeel een backup!
        
    	svn update --accept theirs-full _history 
    	svn rm --force _history
    	svn commit _history -m "Removed _history from repo"
    	rm -rf _history

5. Dan verwijderen we de directory `_valide_content` die abusievelijk in repo zit.
 
    	svn update --accept theirs-full _valide_content 
    	svn rm --force _valide_content
    	svn commit _valide_content -m "Removed _valide_content from repo"
    	rm -rf _valide_content
    Na deze acties is `svn status` wat echt veel tijd kostte (minuten) voorheen al in enkele secondes klaar. Het is dus een nuttige actie.
    
5. **[Robin]** Test moment. Controller dat je nog naar edit pagina kan surfen van willekeurige pagina.
    
6. Dan de plaatjes die in root zijn terecht gekomen. Deze staan zelf niet in repo, maar thumbnail directory `mcith` wel.

    	tar cvfz /tmp/plaatjes-root-repo-20150430.tgz *.jpg *.bmp *.svg *.png *.eps
    	rm *.jpg *.bmp *.svg *.png *.eps
    	svn update --accept theirs-full mcith
    	svn rm --force mcith
    	svn commit mcith -m "Removed thumbnails from root of repo"
    	rm -rf mcith
      
7. Verwijder de ff, stacktrace, done, md5  files: overblijfselen van runs met tools direct in contente tree, niet in repo

    	find . -type f -name ff  -exec rm '{}' \;
    	find . -type f -name stacktrace  -exec rm '{}' \;
    	find . -type f -name done  -exec rm '{}' \;
    	find . -type f -name md5  -exec rm '{}' \;

8. Verwijder de deadjoe files, overblijfselen van locale edits van mensen direct in boom met de editor joe, niet in repo

    	find . -type f -name deadjoe  -exec rm '{}' \;


10. Fout geplaatste plaatjes leiden tot svn update issues (niet bestaande mcith directory, lokaal)

    	cd /opt/data/mathplus/hb/hb-b2/images
    	svn rm --force mcith
    	svn rm --force hb_feg_07_vb4_03_2.png
    	svn commit -m "Image in wrong place"
    	cd /opt/data/mathplus

11. Er staan wat lege directories in hv, niet in repo:

    	rmdir hv/pre1/hv-pre115 
    	rmdir hv/pre1/hv-pre16
    
12. Nog meer rommel van tools (dirs door tools, niet via svn (dus geen .svn))
    
    	cd /opt/data/mathplus/hv/re1
    	rm -rf hv-re1-test-in/
    	svn update
    	cd /opt/data/mathplus    
    	
5. **[Robin]** Test moment. Controller dat je nog naar edit pagina kan surfen van willekeurige pagina.

9. Robin's `components.xml` ignoreren, threads updaten. Surf daarvoor eerst naar 
	- Test: [http://mathpluscms.tst.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Acceptatie: [http://mathpluscms.acc.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Productie: [http://mathpluscms.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
 
9. Dan kunnen we Robin's `components.xml` met onze goede vervangen, maar wel zijn threads kopiëren.

    	svn update --accept mine-conflict leerlijnen
    	svn commit leerlijnen -m "Updated leerlijnen"

13. Overrule veranderingen in index.xml

	    find . -type f -name index.xml -exec svn update --accept mine-full '{}' \;

5. **[Robin]** Test moment. Controlleer dat je nog naar edit pagina kan surfen van willekeurige pagina. Als iets mis gaat, genereer dan indices weer. Alleen nodig als er iets misgaat! Stuur in dat geval ook bericht aan mij.
	- Test: [http://mathpluscms.tst.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Acceptatie: [http://mathpluscms.acc.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Productie: [http://mathpluscms.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()

14. Robin's `vd` directory is op een of andere manier lokaal geplaatst zonder svn in sommige subdirs, die gaan we eerst opruimen en dan pakken we de versie uit svn

    	cd /opt/data/mathplus/vd/vd-b1
    	rmdir vd-b1* # Negeer foutmeldingen
    	svn update
    	cd /op/data/mathplus
   
15. Ik had ook problemen met de index.xml van die directory, maar dat kan komen doordat werkdir en svn op ander
moment door kopie zijn gehaald (mijn werkboom loopt revisies voor op svn repo). Omdat dit een gegenereerde file
is zetten we die even aan de kant. Deze stap kan geen kwaad, ook als hij niet nodig is:

    	svn revert vd/vd-b1/index.xml
	    rm -f vd/vd-b1/index.xml

16. Hierdoor komen weer enkele foute files in de repo (nu met iname: ze zijn uppercase)
    
    	find vd -type f -iname ff  -exec svn rm '{}' \;
	    find vd -type f -iname stacktrace  -exec svn rm '{}' \;
    	find vd -type f -iname done  -exec svn rm '{}' \;
	    find vd -type f -iname md5  -exec svn rm '{}' \;
    	svn commit vd -m "cleaned vd"

17. De directory ha-e4 heeft geen images subdir

    	cd /opt/data/mathplus/ha/ha-e4
	    mkdir -p images/highres
    	mv ha-e41/normale\ verdeling\ leeftijd\ moeders.jpg images/highres
	    rm -rf ha-e41/mcith
    	svn add images
	    svn commit -m "Added images subdir to ha-e4"
    	cd /op/data/mathplus
    
18. Toevoegen van laatste versie van Robin's vd-d1 XML files (zie attachment, zet die in /tmp)
    
    	cd /opt/data/mathplus/vd
	    svn update
    	unzip -o /tmp/vwo\ d1\ en\ threads.zip
	    rm threads.xml # Die hebben we hier niet nodig en deze is identiek aan de svn versie
    	svn add --force vd-d1/
	    svn commit -m "Merged Robin's latest vd-d1"
            
    
20. Omdat boom is veranderd moeten we weer de components.xml en index.xml genereren. Surf weer naar
	- Test: [http://mathpluscms.tst.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Acceptatie: [http://mathpluscms.acc.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()
	- Productie: [http://mathpluscms.malmberg.nl/Publisher/php/GenerateIndex.php?repo=malmberg]()

5. **[Robin]** Test moment. Controller dat je nog naar edit pagina kan surfen van willekeurige pagina.
