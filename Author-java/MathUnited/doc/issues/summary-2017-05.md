# Summary release week 5
 
## Locking issues

### (Temporary fixes)

- http://mathpluscms.tst.malmberg.nl/MathUnited/svn-update?unlock=true to force unlock all locks
- Disabled locking on edit (after svn update)
- Disabled unlocking on commit 

### Communicating through apache

- Avoid simultaneous access through filesystem and apache
- Relocating svn path to server URL involved rechecking out the repo
- GenerateIndices.php does not work on new server adjustments needed to Logger.php script
- User and group of `/opt/sw/mathplus/html` seems wrong: svc_monitoring:arajpal, veranderd naar /opt/sw/mathplus/html
- PHP script kan niet schrijven in leerlijnen...
- Moest /opt/data/mathplus o+w maken om PHP index.xml en components.xml te laten schrijven