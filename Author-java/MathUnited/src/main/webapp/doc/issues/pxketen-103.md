PXKETEN-103 Langzame server
===========================


## Onderzoek

ComponentsMap aanmaken duurt lang omdat for loops veel worden herhaald. 2 ms seconde durende xpath queries tellen
op tot 4000 ms (4s), svn update (2s), svn lock (0.2s)


## Acties

- Cache componentsMap (done)

- Voeg servlet actie toe om reread mogelijk te maken (niet nodig, zie onder)

## 2015-04-11

- Check mtime om te reloaden.