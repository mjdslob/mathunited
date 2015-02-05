CLOZE EDIT DESIGN
=================


# Introductie


# Analyze van voorstellen

[Here](003-cloze-sample-malmberg.xml) staat het design, zoals door Malmberg werd voorgesteld, terwijl
[deze file](004-cloze-sample-our-initial-design.xml) ons design laat zien. We zullen in onderstaande verhaal
de Malmberg-versie aanduiden met M en de MathPlus-versie met P. De belangrijkste verschillen zijn:

1. `<cloze>`: De naam en prefix-naam van subelementen: M: cloze-edit vs. P: cloze. Ik stel voor de -edit te laten
  vallen. Scheelt weer een paar letters en die benaming klopt alleen als het als edit-widget wordt gerenderd. **KEUZE: P**

2. `<cloze-anser score>`: M: state (yes|no) vs P: score (%). Latter is more flexible and incorporate state. **KEUZE: P**

3. `<cloze-answertext>` and `<cloze-correction>` M: cloze-answer heeft children: answertext en correction. P: alleen text. **KEUZE: M**

4. `<cloze-answers><cloze-aswer>...</cloze-answers>` M: cloze heeft zowel hint als answers als children, waar P alleen answers heeft. Hierdoor worden
  de answer's zelf 1 level dieper genest. Dit staat formatting toe van de hint. **KEUZE: M**

5. `<cloze-answers palette>` M: cloze-answers heeft tag `pallette` met keuze. P: heeft dit niet. **KEUZE: M**

6. `<cloze audience>` M: missing, P: heeft **KEUZE: P** <tt>(basic|...)</tt>

7. `<cloze type>`: M: missing, P: heeft. **KEUZE: P** <tt>(text|algebrakit)</tt>

8. `<cloze-answer evaluate>`: M: heeft tag `case-sensitive` maar dat geldt alleen voor text en voor alle answers.
    P: heeft `evaluate` kan zowel voor
    tekst als algebrakit gebruikt worden met *equivalent* voor case-insensitive en *exact* voor case-sensitive, hier
    geldt ook voor hele cloze. Case-sensitivity of equivalence lijkt echter een eigenschap die per antwoord zou
    kunnen verschillen. Bijvoorbeeld je zou Millimeter en millimeter beide goed kunnen tellen maar mm en Mm zijn
    andere dingen. We maken even onderdeel van answer.
   **KEUZE: NEW** <tt>(equivalent|exact)</tt> als attribute van `<cloze-answer>`