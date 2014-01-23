package mathunited;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.Writer;
import java.net.URLDecoder;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import mathunited.configuration.Configuration;
import mathunited.configuration.Repository;

import com.google.appengine.api.datastore.*;


public class PutTextFileServlet extends HttpServlet {
   	    private final static Logger LOGGER = Logger.getLogger(PutTextFileServlet.class.getName());
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
	               throw new Exception("Missing id of the text file");
			   }
			   id = java.net.URLDecoder.decode(id, "UTF-8");

			   String parentId = request.getParameter("parentid");
			   if(parentId!=null) parentId = java.net.URLDecoder.decode(parentId, "UTF-8");

			   String text = request.getParameter("text");
			   if(text==null){
	               throw new Exception("Missing text contents of the file");
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
			   
			   LOGGER.info("PutTextFileServlet: id="+id+", parentId="+parentId+", repo="+repo);
			   
   			   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

   			   //key of resource: repository->component->resourceid
   			   Entity entity;
   		       if(repo.length()>0){
   	   			   Key parentKey = KeyFactory.createKey("Repository", repository.id);
   				   try{
   					   datastore.get(parentKey);
   				   } catch(EntityNotFoundException e) {
   					   Entity repoEntity = new Entity(parentKey);
   					   LOGGER.info("PutTextFileServlet: creating new repository: "+repository.id);
   					   datastore.put(repoEntity);
   				   }
   	   			   if(parentId.length()>0) {
   	   				   parentKey = KeyFactory.createKey(parentKey, "TextFile", parentId);
   	   			   }
   	   			   entity = new Entity("TextFile", id,parentKey);
   		       } else {
   	   			   entity = new Entity("TextFile", id);
   		       }
   			   Text textProp = new Text(text);
   			   entity.setProperty("text", textProp);
   			   entity.setProperty("date", new Date());
   			   Key storedKey = datastore.put(entity);
   			   
   			   if(id.equals("components.xml")) {
   				   Repository.clearCache();
   				   LOGGER.info("Clearing components cache because new components file was uploaded");
   			   }

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
