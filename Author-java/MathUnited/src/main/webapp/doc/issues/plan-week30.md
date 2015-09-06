PXKETEN-60
==========

- h12-re25-exercise-1 is filled with content on test server, even after March 15. Set back by Robin thru svn
- op productie is deze opgave ook gevuld te vinden onder "Practicum"
- svn cat -r565 laat inderdaad een lege versie zien, door user mbos.

WORKING HYPOTHESIS: er is iets misgegaan bij het laden en deze content is gesavet.

PXKETEN-70
==========

- vb-b21 is reeds gesloten (ook op test server) kan niet reproduceren
- Groep van vb/vb-b2/vb-b2.xml staan fout (maakt in principe niet uit, omdat tomcat enige user is)

- h12-me43 is reproduceerbaar op test
- er treedt exceptie op bij ophalen reeds aanwezige referenties (niet bestaande referenties: begint met havo-12 ipv ma-havo-12)
- De foute thread staat in h12-me43-p14.xml


PXKETEN-100
===========

- Editten van genoemde paragraaf is reeds gesloten
- Kan niet reproduceren


PXKETEN-146
===========

Niet te reproduceren, i.e. op huidige pagina kan ik die stappen wel uitvoeren. 

WORKING HYPOTHESIS: browser moet nieuwe Javascript laden (duur even), hard reload