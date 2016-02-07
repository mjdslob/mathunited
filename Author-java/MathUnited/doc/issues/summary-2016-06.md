SUMMARY OF CHANGES 2016 / WEEK 06
=================================


### PXKETEN-440 (AlgebraKit knop)


- Ontwerp
    - Menu voor vraag met deelvragen
        - Knop voor alle AlegbraKIT aan (geen toggle)
        - Geen knop voor alle uit vooralsnog (menu-clutter, lijkt me niet veilig in gebruik:
          risico veel metadata weg te gooien)
        - Vanwege de organisatie van de huidige code komt de knop bij elke deelvraag en
          niet bij de hoofdvraag
            - Menu bij `<item>` (deelvraag) wordt door item gegenereerd
            - Menu bij `<multi-item>` (hoofdvraag) wordt buiten de hoofdvraag (bij `<include>`)
              gemaakt. Op het moment van aanmaken is nog niets bekend van subtype.
    - Als knop wordt geselecteerd worden allen *niet* AlgebraKit deelvragen door
      nieuwe `ToggleAllAlgebraKit.js` aangepast. Er is maar één roundtrip naar server
      nodig voor aanpassing van alle deel vragen.
    - Er komt geen test of alle metadata klopt vóór saven (zie verder voor alternatief)
    - Vraagteken icoon wordt voor AlgebraKit vragen voorzien van extra label (groen steepje)
      welke rood wordt voor AK vragen met lege vraag. Zo zijn incomplete AK vragen
      steeds te herkennen. Kleur van streepje wordt pas na opslaan veranderd.


---

### PXKETEN-461

- `uuid` attributes worden verwijderd bij klonen.
