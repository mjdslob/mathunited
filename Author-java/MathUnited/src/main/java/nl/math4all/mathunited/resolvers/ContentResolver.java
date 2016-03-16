package nl.math4all.mathunited.resolvers;

import javax.servlet.ServletContext;
import javax.xml.transform.URIResolver;
import org.xml.sax.InputSource;
import org.xml.sax.helpers.XMLReaderFactory;
import org.xml.sax.EntityResolver;
import org.xml.sax.XMLReader;
import javax.xml.transform.sax.SAXSource;
import java.io.*;
import org.xml.sax.SAXException;
import nl.math4all.mathunited.configuration.*;
import java.util.Map;
/**
 *
 * @author martijn
 */
public class ContentResolver implements URIResolver{
    /** resolves uri from document(), include() and import() in stylesheet */

    ServletContext context;
    private Repository repository;
    
    public static EntityResolver entityResolver = new EntityResolver() {
          public InputSource resolveEntity (String publicId, String systemId)
           {
              try {
                  if(systemId.endsWith("entities.xml")) {
                      Configuration config = Configuration.getInstance();
                      InputStream entitiesStream = new FileInputStream(config.getEntitiesFile());
                      return new InputSource(entitiesStream);
                  }
              }catch(IOException e) {
                  System.out.println("Could not load entities file.");
              }
              return null;
           }
    };

    public ContentResolver(Repository repo, ServletContext context) {
        this.context = context;
        this.repository = repo;
    }
    
    
    public SAXSource resolve(String href, String base)  {
        Configuration config = Configuration.getInstance();
        InputSource xmlSource = null;
        try{
            if(href != null) {
                if(href.endsWith("entities.xml"))   {
                    InputStream is = new FileInputStream(config.getEntitiesFile());
                    xmlSource = new InputSource(is);
                } else if(href.endsWith(".xml")) {
                    Map<String, Repository> map = config.getRepos();
                    String baseRepoStr = repository.baseRepo;
                    Repository baseRepository = map.get(baseRepoStr);
                    File f = new File(config.getContentRoot() + href);
                    if(!f.exists() && baseRepository!=null) {
                        //if file does not exist, use from default repo
                        String hrefBase = href.replace(repository.getPath(), baseRepository.getPath());
                        System.out.println("Falling back to default repository for "+hrefBase+": using "+href);
                        f = new File(config.getContentRoot() + hrefBase);
                    }
                    InputStream is = new FileInputStream(f);
                    xmlSource = new InputSource(is);
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
        }  catch(SAXException e)  {
            System.out.println("Could not load XML parser.");
        }  catch(Exception e) {
            e.printStackTrace();
        }  
        System.out.println("Could not resolve "+href);
        return null;
    }
    
    
}
