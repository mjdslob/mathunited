package mathunited;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;


@SuppressWarnings("serial")
public class PutXmlFileServlet extends HttpServlet {
   	    private final static Logger LOGGER = Logger.getLogger(PutXmlFileServlet.class.getName());
   	    ServletContext context;

        public void init(ServletConfig config) throws ServletException {
            try{
                super.init(config);
                context = getServletContext();
       	        LOGGER.setLevel(Level.INFO);
            } catch(Exception e) {
            	LOGGER.severe((new StringBuilder("Init of PutTextFileServlet failed")).append(e.getMessage()).toString());
            }
        }

        @Override
	    public void doPost (  HttpServletRequest request, HttpServletResponse response)
	             throws ServletException, IOException {
		   
    	   try{
               Configuration config = Configuration.getInstance(context);

               String id = request.getParameter("id");
			   if(id==null){
	               throw new Exception("Missing id of the xml file");
			   }
			   id = java.net.URLDecoder.decode(id, "UTF-8");

			   String text = request.getParameter("text");
			   if(text==null){
	               throw new Exception("Missing contents of the file");
			   }
			   text = java.net.URLDecoder.decode(text, "UTF-8");
			   String repo = request.getParameter("repo");
			   if(repo==null){
	               throw new Exception("Missing repo identifier for the resource");
			   }
			   repo = java.net.URLDecoder.decode(repo, "UTF-8");
			   
			   Repository repository = config.getRepos().get(repo);
	           if(repository==null) {
	                throw new Exception("Onbekende repository: "+repo);
	           }
			   
			   LOGGER.info("PutXmlFileServlet: id="+id+", repo="+repo);
			   
   			   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

   			   //key of resource: repository->component->resourceid
   			   Entity entity;
   		       if(repo.length()>0){
   	   			   Key parentKey = KeyFactory.createKey("Repository", repository.id);
   				   try{
   					   datastore.get(parentKey);
   				   } catch(EntityNotFoundException e) {
   					   Entity repoEntity = new Entity(parentKey);
   					   LOGGER.info("PutXmlFileServlet: creating new repository: "+repository.id);
   					   datastore.put(repoEntity);
   				   }
   	   			   entity = new Entity("XmlFile", id,parentKey);
   		       } else {
   	   			   entity = new Entity("XmlFile", id);
   		       }
   			   Text textProp = new Text(text);
   			   entity.setProperty("text", textProp);
   			   entity.setProperty("date", new Date());
   			   Key storedKey = datastore.put(entity);
   			   
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               
               pw.println("info: " + KeyFactory.keyToString(storedKey));
   			   
    	   } catch (Exception e) {
               e.printStackTrace();
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println("error: "+e.getMessage());
               throw new ServletException(e);
           }
	   } 

}
