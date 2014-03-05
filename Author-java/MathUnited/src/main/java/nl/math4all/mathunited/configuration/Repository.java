package nl.math4all.mathunited.configuration;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;
import org.xml.sax.InputSource;

/**
 *
 * @author martijnslob
 */
public class Repository {
    public String path;
    public String edit_permission;
    public String defaultVariant;
    public String baseRepo;
    
    public Map<String, Component> readComponentMap() throws Exception {
        Configuration config = Configuration.getInstance();
        File f = new File(config.contentRoot+this.path+"/leerlijnen/components.xml");
        if(!f.exists() && this.baseRepo!=null && !this.baseRepo.isEmpty()) {
            Repository baseRepo = config.getRepos().get(this.baseRepo);
            f = new File(config.contentRoot+baseRepo.path+"/leerlijnen/components.xml");
        }
        FileInputStream is = new FileInputStream(f);
        Map<String, Component> componentMap = Component.getComponentMap(new InputSource(is));
        is.close();

        return componentMap;
    }
}

