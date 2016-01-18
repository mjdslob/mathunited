# PXKETEN 381

- Added locking code to svn-update-paragraph.zsh

- Added unlocking code to svn-commit-paragraph.zsh


# PXKETEN 370

- Content error in clone xml files. Er staat abusievelijk twee <clone> elementen in terwijl er maar 1 mag. 

    - `/hb/hb-c3/hb-c32/hb-c32-os1-clone.xml`
    
    - `/hb/hb-c3/hb-c33/hb-c33-ex-4-clone-1.xml`
    
    - `/hb/hb-c3/hb-c31/hb-c31-os1-clone-1.xml`

- De foutmelding komt van XSLT. Dit wijst doorgaans op een fout in de XML, dus niet van de auteurstool. 
  Moet dit specifieker worden afgevangen en duidelijker worden gerapporteerd door de auteurstool?
  
