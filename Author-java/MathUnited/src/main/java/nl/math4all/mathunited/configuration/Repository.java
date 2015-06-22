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
    private String path;
    public String edit_permission;
    public String defaultVariant;
    public String baseRepo;
    public String componentsURL;
    public String threadsURL;
    public String contentItems;

    //componentMap cannot be static as this servlet can be used for multiple
    //repositories on the same server (e.g. Math4All, Wageningse Methode)
    private Map<String, Component> componentMap = null;
    private long componentMtime = 0L;

    /**
     * Read the component if it has not been read yet, or return a cached copy.
     *
     * @return The component map
     * @throws Exception
     */
    public Map<String, Component> readComponentMap() throws Exception {

        Configuration config = Configuration.getInstance();
        File f = new File(config.contentRoot + this.getPath() + "/leerlijnen/components.xml");

        if (componentMap != null && f.lastModified() <= componentMtime) {
            return componentMap;
        }


//        File f = new File("/var/www/html/index/studiovo/components.xml");
        if(!f.exists() && this.baseRepo!=null && !this.baseRepo.isEmpty()) {
            Repository baseRepo = config.getRepos().get(this.baseRepo);

            f = new File(config.contentRoot+baseRepo.getPath()+"/leerlijnen/components.xml");
        }
        FileInputStream is = new FileInputStream(f);

        componentMap = Component.getComponentMap(new InputSource(is));
        componentMtime = f.lastModified();

        is.close();

        return componentMap;
    }

    /**
     * @return the path
     */
    public String getPath() {
        return path;
    }

    /**
     * @param path the path to set
     */
    public void setPath(String path) {
        this.path = (path==null?"":path);
    }
}

