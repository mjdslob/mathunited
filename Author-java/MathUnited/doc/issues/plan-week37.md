Algemeen
========

- Externe CSS voor Roboto van googlefontapi verwijderd: beïnvloedde laadtijd negatief

PXKETEN-194
===========

- Als nazorg "--accept mine-conflict" toegevoegd aan svn-update commando
 
PXKETEN-197
===========
 
- Fout treedt op als Http request parameter wel 'comp' bevat maar deze leeg is.
- Betere (leeg ipv null) checks tegen lege component en subcomponent ID's toegevoegd
- Extra log code toegevoegd aan PostContentServlet
- editor/Main.js check aan begin of component-ID bekent is, zodat gebruiker niet ter vergeefs gaat editten.
- **Graag deze extra berichten + tijdstip bij volgende melding, zodat ik kan kijken in Tomcat log wat daar de meldingen waren.**


PXKETEN-216
===========

- De volgende stappen moeten op de productie server worden uitgevoerd

    mv /opt/data/mathplus/vd/vd-b1/vd-b12/vd-b12-ex-4.xml /tmp
    svn update --accept mine-conflict /opt/data/mathplus/vd/vd-b1/vd-b12
    cp /tmp/vd-b12-ex-4.xml /opt/data/mathplus/vd/vd-b1/vd-b12/vd-b12-ex-4.xml
    svn commit /opt/data/mathplus/vd/vd-b1/vd-b12 -m "Auteurstool versie van vd-b12-ex-4.xml"
   
- Standaard pakken we nu de auteurs versie als dominant. Ik kan deze fouten door tool laten checken en bovenstaande
  stappen altijd laten uitvoeren. **Is dit gewenst of is menselijk ingrijpen wenselijk?** Mijn observatie is dat
  we nu altijd deze stappen uitvoeren, dus automatisch kan ook.
  
PXKETEN-213
===========

- Genoemde paragrafen staan niet in actuele leerlijnen
- svn-update blijf idd hangen op PXKETEN-216
- svn update bij mij versie van svn loopt gewoon door bij dit soort problemen (svn, version 1.8.13 (r1667537))
- **OPLOSSING voor volgende keer:** Subdirectories zijn wel up-te-daten met (werk nu al):

    http://mathpluscms.malmberg.nl/MathUnited/svn-update?path=/leerlijnen

- Na die update nog steeds geen referentie naar vd-d2-test-in in components.xml en leerlijnen.xml 
- Voorstel: **Ciber update svn-software op server naar zelfde als ik lokaal heb**

PXKETEN-199
===========

- Verstuurd


    



    