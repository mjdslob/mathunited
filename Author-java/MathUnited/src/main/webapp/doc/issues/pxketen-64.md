PXKETEN-64 EVEN GEDULD AUB
==========================


# Introductie

Tool blijft af en toe hangen op "Even geduld aub".

# Analyse

Niet reproduceerbaar geheel reproduceerbaar op test server met huidige internet verbindingen. 
Ik heb wel eerder waargenomen dat tool kan blijven hangen op MathJax.

Een tijdsanalyse van een pageload:

- 9000 ms: reactie van server. In tussentijd doet hij waarschijnlijk eerst een svn update en dan lock. Duurt dit 
inderdaad 9 seconden. Merk op: Even geduld aub komt pas na reactie van server, dus dit is verder niet de oorzaak.

- 150 ms is typische tijd om resource (javascript of plaatje) van server op te halen

Non-local communicatie: alleen met http://cdn.mathjax.org/mathjax/latest/

- 500 ms duurt laden van MathJax js (http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML&amp;delayStartupUntil=configured&bust=v29). Maar deze laadt zelf nog meer

- Nog eens 500 ms:  http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML&amp;delayStartupUntil=configured&bust=v29

    - 100 ms http://cdn.mathjax.org/mathjax/latest/config/TeX-AMS_HTML.js?rev=2.5.1
    
    - 100 ms http://cdn.mathjax.org/mathjax/latest/config/MMLorHTML.js?rev=2.5.1
    
    - 50 ms http://cdn.mathjax.org/mathjax/latest/jax/input/MathML/config.js?rev=2.5.1
    
    - 200 ms http://cdn.mathjax.org/mathjax/latest/jax/input/AsciiMath/config.js?rev=2.5.1
    
    - 200 ms http://cdn.mathjax.org/mathjax/latest/extensions/mml2jax.js?rev=2.5.1
    
    - 200 ms http://cdn.mathjax.org/mathjax/latest/extensions/asciimath2jax.js?rev=2.5.1
    
    - 50 ms http://cdn.mathjax.org/mathjax/latest/jax/input/AsciiMath/jax.js?rev=2.5.1
    
    - 50 ms http://cdn.mathjax.org/mathjax/latest/jax/output/HTML-CSS/jax.js?rev=2.5.1 (inderdaad sommig meerdere keer)
    
    - 200 ms http://cdn.mathjax.org/mathjax/latest/jax/output/HTML-CSS/fonts/STIX/fontdata.js?rev=2.5.1
    
- Het laden van overige javascripts kost ook seconden door 
    
Gebruik van de MathJax CDN server valt onder de TOS op http://www.mathjax.org/mathjax-cdn-terms-of-service.html

Mathjax kan ook lokaal worden gedraaid.
    

# Acties

- Voeg timing toe aan SVN commando's (open)

- Verwijder bust=v29 van URI naar MathJax

- Maak MathJax lokaal beschikbaar (open)

