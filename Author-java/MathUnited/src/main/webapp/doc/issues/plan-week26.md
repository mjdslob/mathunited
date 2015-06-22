PXKETEN-138 & Github sync
=========================

- Gesynct met github en kleine fix aangebracht

- Geen timing problemen


PXKETEN-143
===========

- Permissies verkeerd (gebruiker van dir is tomcat:tomcat ipv tomcat:mathplus waar door GenerateIndices.php dat als
  gebruiker apache:apache draait, de index.xml file niet kan updaten.
  
- FIX: Maarten permissies aan laten passen


PXKETEN-138
===========

- Via Martijn en Gitbub sync (zie boven)

PXKETEN-72
==========

Kan nog niet repliceren -> Robin en auteur vragen om text


PXKETEN-139
===========

- Lokaal en op acceptatie kunnen zowel nieuwe als bestaande meta data worden ingevuld. Voorbeeld:

    a. Publisher > Bewerken > VWO Leerjaar 1 > Symmetrie > 6. Draaisymmetrie
    
    b. Verwerken > 8e opgave "Je ziet ... Maak de figure compleet op het werkblad" met
       rechthoek, ellips, driehoek
    
    c. Balletje links van opgave > Metadata invullen
    
    d. **NIET OP PRODUCTIE!!!** Verander metadata , e.g. niveau 3 > 4, soort opgave van niks naar kangaroe, 
       leerdoel toevoegen "het draaicentrum van een figuur aanwijzen", voeg gerelateerde theorie toe
       "VWO leerjaar 1 » Symmetrie » Draaisymmetrie » voorbeeld 2". 
       
    e. Opslaan
    
    f. Controlleer nadat pagina is herladen dan idd metadata veranderd is
    
    (zelf op test gedaan en weer terug gezet)
    
- Nieuwe opgave is ook eenvoudig te testen

- FIX heeft meet info nodig. Mogelijk wordt dit nu veroorzaakt op specifieke XML's graag meer metadata dan. Ook 
  versie en "merk" van browser zou een informatie kunnen bieden omdat we veel Javascript gebruiken.

PXKETEN-127
===========

Omdat de JIRA issues dit specifieke probleem zelf als opgelost verklaard, kan ik dit niet onderzoeken. 


Net als 139 en 127, is hier voor preciezere informatie nodig. Omdat de server zaken commit als een gebruiker na een edit wegsurft
van een paragraaf, kan svn hier een oplossing vinden. De gebruiker moet dan:

a. Wegsurfen van de pagina

b. URL en precieze tijdstip mailen aan support team (en mij), we kunnen dan in SVN de voor en na bekijken van all
   xml files in een directory, en Robin's opmerking onderzoeken, dat een opgave soms niet mee wordt genomen in de
   paragraaf-index xml van die directory. (Dat zou betekenen dat deze niet in browser stond, dus dat het bij het xslt
   processen en downloaden naar auteurs-tool van de gebruiker niet mee is genomen om een of andere reden. Mijn 
   vermoeden is dan dat de XSLT processor een file laat liggen, maar ik zou graag zien waarom: overload? Permissies?
    