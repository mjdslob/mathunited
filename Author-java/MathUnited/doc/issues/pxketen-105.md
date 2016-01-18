PXKETEN-105 Content tree opschonen
==================================

## 2015-04-12

OPMERKING: Onderstaande paden zijn t.o.v. van de root van de werk directory, dus als een pad begint met een `/` 
           wordt er de data-root bedoeld

1. Staat in content, niet in Subversion maar zou wel moeten ( **actie:** `svn add`)

    a. geogebra subdirectories, e.g. `/vc/vc-d1/geogebra`
    
2. Staat in content, niet in Subversion, zou uit werkdirectory moeten ( **actie:** `rm -f`)

    a. Plaatjes in data-root directory, e.g. `hd_sta_01_ui_0.png` alsmede de gegenereerde thumbnails in 
      `/mcith`
    
    b. de zipfiles in `/_history`
    
    c. De door andere tools aangemaakte files `ff`, e.g. `/hv/gr7/ff`
    
    c. De door andere tools aangemaakte files `md5`, `stacktrace`, en `done`, e.g.
        
        vd/vd-d3/vd-d33/stacktrace        
        vd/vd-d3/vd-d33/md5        
        vd/vd-d3/vd-d33/done
    
    
3. Staat in content en in Subversion, maar zou alleen in content moeten staan ( **actie:** `svn rm`, dan `svn-ignore` property zetten, dan hergenereren)

    a. De gegenereerde file `/leerlijnen/components.xml`
    
    b. De per sectie genenereerde file `index.xml`, e.g. `hv/gr1/index.xml` 
    
4. Staat in content en in Subversion, moet helemaal weg ( **actie:** `svn rm`)
 
    a. de `log.xml` files in `/_history`
    
    b. `/_history` zelf
    
    c. `/_valide_content`

5. Staat in content en in Subversion, mag dat?

    a. Directories met underscore (verborgen directories), e.g. `/hv/_re3`
    
    b. Laatste PXKETEN-59 melding: naam met spatie `/h12/if1/h12-if14/h12-if14-u1 oud.xml`

## Actie punten week 16:

- Feedback over voorgestelde acties

- Maarten content van prd/acc naar tst om acties te testen

