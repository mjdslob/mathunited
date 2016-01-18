SUMMARY OF CHANGES 2016 / WEEK 01
=================================


## Onbenoemd

- Fix voor potentiële memory leak / servlet restart probleem

    - Timer thread manager voor lock controle liep mogelijk door na servlet herstart

## PXKETEN 343

1. ~~Via setAttributeNS vervangen we noNamespaceSchemaLocation tag~~

    - ~~Randvoorwaarden~~

        - ~~we verwachten `xsi` namespace dus doel is `xsi:noNamespaceSchemaLocation`.~~

        - ~~xsi namespace moet gedefinieerd zijn als `xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'`, met die exacte URL.~~

2. Eenvoudige string replacement bij submit

3. Deze wordt weer teniet gedaan door TAG SOUP html clean up…

4. **FIX:** Dus we runnen ook een script op server na het schrijven... Geïmplementeerd & getest.


## PXKETEN 344

- **Probleem:** Voorwaartse XSLT trafo gaat mis.<br/>
  **Oorzaak:** `<am>` en `<m:math>` draaien in `"paragraph"`-modus, maar `<subcaption>` in `"table"`-modus.<br/>
  **FIX:** `table` toegevoegd in whitespace seprated moduslijst voor de match van zowel `<am>` als `<m:math>`.



- **Probleem:** Inverse transform plaatst spaties verkeerd.<br/>
  **Analyse:**
    - ~~In Javascript's terugstuur-document staat `<div tag="am"/>` netjes met whitespace in omhullende `<p>`.~~
    - In developer modus in browser staat in ene view `<span tag="am-container"><span tag="am">`, terwijl er
      via andere JQuery selector and wat naar server wordt gestuurd `<div = am>` is.

  **Temp FIX:** Er wordt een spatie voor en na `<am />` elementen geplaatst

