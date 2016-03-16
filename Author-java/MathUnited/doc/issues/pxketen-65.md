PXKETEN-65 Lock verdwenen
=========================

- Tegelijkertijd bewerken van pagina

- Mogelijke oorzaak race conditie bij zetten lock

# Onderzoek

- Kleine bugs in lock generatie code 

   - synchronized blocken van LockManager
    
     - Opgelost door gebruik van ConcurrentHashMap
     
     - Nog steeds synchronized block om tijd tussen check of key voorkomt en insertie van nieuwe lock 
       te overbruggen
    
   - Iterator over HashMap leek niet Locks uit die man te halen (itereerde over values, verwijderde 
      elementen uit Set die values ziet, niet duidelijk of dit ook HashMap zelf veranderde), dit
      is nu aangepast om expliciet


# Acties

- Onderzoek (open)

- Lock synchronisatie fixen (test)