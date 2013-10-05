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


public class GetTextFileServlet extends HttpServlet {
	    private final static Logger LOGGER = Logger.getLogger(GetTextFileServlet.class.getName());
	    ServletContext context;

        public void init(ServletConfig config) throws ServletException {
            try{
                super.init(config);
                context = getServletContext();
            } catch(Exception e) {
            	LOGGER.severe((new StringBuilder("Init of GetTextFileServlet failed")).append(e.getMessage()).toString());
            }
        }

        @Override
	    public void doGet (  HttpServletRequest request, HttpServletResponse response)
	             throws ServletException, IOException {
		   
 		   LOGGER.setLevel(Level.INFO);
           Configuration config = Configuration.getInstance(context);

    	   try{
    		   String id = request.getParameter("id");
			   if(id==null){
	               throw new Exception("Missing id of the text file");
			   }
			   id = java.net.URLDecoder.decode(id, "UTF-8");

			   String parentId = request.getParameter("parentid");
			   if(parentId!=null) parentId = java.net.URLDecoder.decode(parentId, "UTF-8");

			   String repo = request.getParameter("repo");
			   if(repo!=null) repo = java.net.URLDecoder.decode(repo, "UTF-8");
			   Repository repository = config.getRepos().get(repo);
	           if(repository==null) {
	                throw new Exception("Onbekende repository: "+repo);
	           }
			   			   			   
   			   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

   			   //key of resource: repository->component->resourceid
   			   Key key = null;
   		       if(repo==null){
   		    	   key = KeyFactory.createKey("TextFile", id);
   		       } else {
   	   			   Key parentKey = KeyFactory.createKey("Repository", repository.id);
   	   			   if(parentId!=null) {
   	   				   parentKey = KeyFactory.createKey(parentKey, "TextFile", parentId);
   	   			   }
   	   			   key = KeyFactory.createKey(parentKey, "TextFile", id);
   		       }
	   		   Entity entity = datastore.get(key);
   			   Text textProp = (Text)entity.getProperty("text");
     		   // Specify domains from which requests are allowed
   			   response.addHeader("Access-Control-Allow-Origin", "*");
     	       // Specify which request methods are allowed
   			   response.addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
   			   // Additional headers which may be sent along with the CORS request
   			   // The X-Requested-With header allows jQuery requests to go through
   			   response.addHeader("Access-Control-Allow-Headers", "X-Requested-With");

   			   Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println(textProp.getValue());
    	   } catch (Exception e) {
               e.printStackTrace();
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println("error: "+e.getMessage());
               throw new ServletException(e);
           }
	   } 

}
