SUMMARY OF CHANGES 2016 / WEEK 01
=================================

## VPN

Werkt nu. Yippee.

## PXKETEN 385

1. Algemene fixes aan image resources (buiten `paperfigure`):

    1. `<resource>` roundtrip verloor **`type='graphic'`** attribute: FIXED.
       Het attribute
       wordt niet meegegeven in trafo in `figure.xslt`, maar voor images wordt
       altijd `type='graphic'` toegevoegd in `inverse.xslt`.

    1. `<resource>` rountrip verloor **`<owner>`** child: FIXED. Owner wordt
       bij transformatie als `owner="..."` attribuut in `<img>` tag opgeslagen door `figure.xslt`
       en daar door weer uitgehaald door `inverse.xslt`.

    1. `<resource>` rountrip verloor **`<id>`** child: FIXED. Owner wordt
       bij transformatie als `resource_id="..."` attribuut in `<img>` tag opgeslagen
       om niet verward te worden door het bestaande HTML attribuut `id`. Dit gebeurd
       weer in `figure.xslt`
       en de terug trafo door `inverse.xslt`.

    1. Alleen `'<width>'` werd bij roundtrip gekopieerd, via het attribuut
       `paperwidth` dat aan een `<img>` tag wordt toegevoegd. FIXED. **We doen nu hetzelfde
       voor `<height>`** als deze (dezelfde conditie als `<width>`) groter is dan 0.

    1. **VRAAG**: de elementen `<id>`, `<owner>`, `<width>`, `<height>`, `<description>` worden ook aan XML toegevoegd
       als deze leeg zijn. Is dit inderdaad de bedoeling? Ik kan deze ook alleen toevoegen als ze een waarde hebben.

2. `<paperfigure>` aanpassingen:

    1. Dezelfde als hierboven voor figuren in algemeen

    2. Ook `<caption>` wordt geroundtript

    3. Ook `type="..."` attribuut van `<paperfigure>` wordt geroundtript via `figure_type` (default: c)

    4. Ook `id="..."` attribuut van `<paperfigure>` wordt geroundtript via `figure_id` (naast `resource_id` van hierboven) (default: *)

    5. Ook `label="..."` attribuut van `<paperfigure>` wordt geroundtript via `figure_label` (default: *)

    5. Ook `reset="..."` attribuut van `<paperfigure>` wordt geroundtript

    1. **VRAAG**: Ook hier worden al de nodes en attributen leeg of met default waarde
       toegevoed als ze lee zijn. Is dit inderdaad de bedoeling? Ik kan deze ook alleen toevoegen als ze een waarde hebben.

3. `<inlinefigure>` aanpassingen

    1. Eigen trafo toegevoegd naar voorbeeld van `<paperfigure>` met volgende verschillen:

        1. Er is geen `<caption>` child node

        2. Er zijn geen attributen `location`, `paperlocation` en `reset`

        3. De attributen `id`, `label` en `type` worden geroundtript maar worden niet
        met standaard waarden ingevuld als ze niet in XML bestonden

        4. Aan resource wordt `type="graphic"` toegevoegd

    2. TinyMCE aanpassingen voor inline figures

        1. Voeg niet altijd `class="paperfigure"` toe

        2. Minder console logging

    3. Fix voor PXKETEN-385: inlinefigure loopt in `paragraph` mode, zodat
       er geen nieuwe paragrafen worden gemaakt.

4. Nog een geconstateerde problemen:

    1. De tekst

           <i>Algebra</i><b>Kit</b>

       wordt na roundtrip tot

           <i>Algebra</i>
                <b>Kit</b>

       vernaggeld. Dit is NOT FIXED.


## PXKETEN 343

1. Onderzoek:

    1. Case switch komt al na laden: HTML heeft case insensitive objecten en de DOM maakt deze lowercase.

    2. Om dezelfde reden (editten gebeurd in HTML) kan ik met jQuery noch javascript direct op de DOM
       de case goed maken.

    3. Bij de terugtransformatie via XSLT gaat alles via nette XML, maar dan zit
       xsi:nonamespaceschemalocation niet in XSI namespace en wordt de transformatie niet uitgevoerd.

    4. Laatste mogelijke fix: pas bij saven kunnen we dit attribuut hernoemen... Moet in Java
       nog niet uitgevoerd. **VOLGENDE RELEASE**