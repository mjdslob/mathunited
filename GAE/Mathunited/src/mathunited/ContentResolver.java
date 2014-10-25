package mathunited;

import com.google.appengine.api.datastore.*;

import javax.servlet.ServletContext;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;

import org.xml.sax.InputSource;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.EntityResolver;
import org.xml.sax.XMLReader;

import javax.xml.transform.sax.SAXSource;

import java.net.URL;
import java.io.*;
import java.net.MalformedURLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Map;

import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;

import org.xml.sax.SAXException;

public class ContentResolver implements URIResolver {
    /** resolves uri from document(), include() and import() in stylesheet */
	private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
	static {LOGGER.setLevel(Level.INFO);}
    ServletContext context;
    private String repo;
    private String parentId;
    
    public EntityResolver entityResolver = new EntityResolver() {
          public InputSource resolveEntity(String publicId, String systemId) {
             if(systemId.endsWith("entities.xml")) {
                 InputStream entitiesStream = context.getResourceAsStream("/entities.xml");
                 return new InputSource(entitiesStream);
             }
 			 return null;
          }
    };

    public ContentResolver(String repo, String parentId, ServletContext context) {
        this.context = context;
        this.repo = repo;
        this.parentId = parentId;
    }
    
    public Source resolve(String href, String base)  {
        try{ 
        	if( href.startsWith("../")) {
        		href = href.replace("../","");
        		base="root"; 
        	}
//        	LOGGER.info("MSLO: resolving href="+href+", base="+base); 
        	Configuration config = Configuration.getInstance();
            InputSource xmlSource = null;
	        if(href != null) {
	            if(href.endsWith("entities.xml"))   {
	                InputStream is = context.getResourceAsStream("/entities.xml");
	                if(is==null) LOGGER.severe("Could not find entities.xml");
	                xmlSource = new InputSource(is);
	            } else if(href.endsWith(".xml")) {
                    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
                    Map<String, Repository> map = config.getRepos();
                    Repository repository = map.get(repo);
             	    Key repoKey = KeyFactory.createKey("Repository", repository.id);
                	Key parentKey = KeyFactory.createKey(repoKey, "TextFile", parentId);
	                try    {
		                Key key;
	                    if(base.equals("root")) {
	    	                key = KeyFactory.createKey(repoKey, "TextFile", href);
	                    } else {
	    	                key = KeyFactory.createKey(parentKey, "TextFile", href);
	                    }
		                Entity file = datastore.get(key);
		                Object obj = file.getProperty("text");
		                if(obj instanceof Text)   {
		                    Text textProp = (Text)obj;
		                    String str = textProp.getValue();
		                    StringReader reader = new StringReader(str);
		                    xmlSource = new InputSource(reader);
		                }
	                } catch(EntityNotFoundException e) {
	                	if(base.equals("root")){
	                		LOGGER.severe("Could not find entity in DataStore: href="+href+" (parent=repo)");
	                	} else {
	                		LOGGER.severe("Could not find entity in DataStore: href="+href+", parentKey="+parentKey.toString());
	                	}
	                } catch(Exception e) {
	                    e.printStackTrace();
	                    LOGGER.severe((new StringBuilder("Error occured: ")).append(e.getMessage()).toString());
	                }
	            } else if(href.endsWith(".xslt")) {
	                InputStream is = context.getResourceAsStream("/xslt/"+href);
	                xmlSource = new InputSource(is);
	            }
	        }
	        if(xmlSource != null) {
               XMLReader xmlReader = XMLReaderFactory.createXMLReader("org.apache.xerces.parsers.SAXParser");
               xmlReader.setEntityResolver(entityResolver);
               SAXSource xmlSaxSource = new SAXSource(xmlReader, xmlSource);
               return xmlSaxSource;
	        }
        }  catch(Exception e) {
            LOGGER.info("MSLO: resolving exception");
            e.printStackTrace();
        } 
        return null;
        
    }


}
