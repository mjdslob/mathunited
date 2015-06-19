package mathunited.configuration;

import java.io.StringReader;
import java.util.Map;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import mathunited.XSLTbean;

import org.xml.sax.InputSource;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;

public class Repository {
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    static {LOGGER.setLevel(Level.INFO);}
	/** index of available components in this repository */
    private static Map<String, Map<String, Component>> componentMaps = new HashMap<String, Map<String, Component>>();
	
    public String id;
	public String path;
    public String edit_permission;
    public String defaultVariant;
    public String baseRepo;
    public String defaultResultVariant;
    public String defaultLoginVariant;
    
    public static void clearCache() {
    	componentMaps.clear();
    }
    
    public synchronized Component getComponent(String component_id) throws Exception {
    	Map<String, Component> componentMap = componentMaps.get(id);
    	if(componentMap==null) {
            //read components-overview 
    		Key parentKey = KeyFactory.createKey("Repository", id);
   			if(parentKey==null) {
   				throw new Exception("Repository "+id+"not found: cannot read components index");
   			}
  	        Key key = KeyFactory.createKey(parentKey, "TextFile", "components.xml");
            DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
           	Entity file = datastore.get(key);
            Object obj = file.getProperty("text");
            if(obj instanceof Text)   {
                Text textProp = (Text)obj;
                String str = textProp.getValue();
                StringReader reader = new StringReader(str);
                InputSource xmlSource = new InputSource(reader);
                componentMap = Component.getComponentMap(xmlSource);
                componentMaps.put(id, componentMap);
            } else {
            	throw new Exception("Program error");
            }
    	}

    	return componentMap.get(component_id);
    }
}
