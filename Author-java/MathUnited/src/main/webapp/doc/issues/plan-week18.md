# Plan week 17

## SVN-update

- Bij tweede en derde call laat nu de update servlet de huidige progress zien van het update proces dat al draait

- svn update vanuit tool in dir met conflicts genereert meerdere files, maar svn update blijft niet hangen

- svn-update en svn-status accepteren een path, e.g. http://127.0.0.1/MathUnited/svn-update?path=leerlijnen of
  http://127.0.0.1/MathUnited/svn-update?path=/leerlijnen . We controlleren altijd of resulterend pad een subpad
  is van de contentroot, zodat http://127.0.0.1/MathUnited/svn-update?path=leerlijnen/../../aap niet uot de repo 
  kan breken. De gebruiker krijgt dat een error message te zien.
   

