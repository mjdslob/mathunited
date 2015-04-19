package mathunited;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
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

import com.google.appengine.api.blobstore.BlobInfo;
import com.google.appengine.api.blobstore.BlobInfoFactory;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

public class GetResourceServlet extends HttpServlet {

	private static final long serialVersionUID = -2773787622214162347L;
		
		private final static Logger LOGGER = Logger.getLogger(GetResourceServlet.class.getName());
        private final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
		private final BlobInfoFactory infoFactory = new BlobInfoFactory();
	    private final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    ServletContext context;

        public void init(ServletConfig config) throws ServletException {
            try{
                LOGGER.setLevel(Level.INFO);
                super.init(config);
                context = getServletContext();
            } catch(Exception e) {
            	LOGGER.severe((new StringBuilder("Init of GetResourceServlet failed")).append(e.getMessage()).toString());
            }
        }
	    
        @Override
	    public void doGet (  HttpServletRequest request, HttpServletResponse response)
	             throws ServletException, IOException {
 		   String blobKeyStr = request.getParameter("blob-key");
 		   if(blobKeyStr!=null) getFromBlobKey(blobKeyStr, request,response);
 		   else {
 			   String repo = request.getParameter("repo");
 			   String subcomp = request.getParameter("subcomp");
 			   String type = request.getParameter("type");
 			   String id = request.getParameter("id");
 			   if(repo==null) {
 				   throw new ServletException("Could not retrieve resource: missing repository identifier");
 			   }
 			   if(id==null) {
 				   throw new ServletException("Could not retrieve resource: missing resource id");
 			   }
 			   if(type==null) {
 				   type="TextFile";
 			   }
 			   getFromDataStore(repo, subcomp, id, type, request,response);
 		   }
        }
        
        private void getFromDataStore(String repo, String subcomp, String id, String type, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            try{
                Configuration config = Configuration.getInstance(context);
                Repository repository = config.getRepos().get(repo);
                if(repository==null) {
                	throw new ServletException("Unknown repository: "+repo);
                }
	   			Key parentKey = KeyFactory.createKey("Repository", repository.id);
	   			if(subcomp!=null) {
	   				parentKey = KeyFactory.createKey(parentKey, "TextFile", subcomp);
	   			}
	   			Key key = KeyFactory.createKey(parentKey, type, id);
 	   		    Entity entity = datastore.get(key);
 	   		    String blobKeyStr = (String)entity.getProperty("blob-key");
	   			getFromBlobKey(blobKeyStr, request, response);
            } catch (Exception e) {
                   e.printStackTrace();
                   Writer w = response.getWriter();
                   PrintWriter pw = new PrintWriter(w);
                   pw.println("error: "+e.getMessage());
                   throw new ServletException(e);
            }
    	} 
        
        private void getFromBlobKey(String blobKeyStr, HttpServletRequest request, HttpServletResponse response) 
        	throws ServletException, IOException {
        	try{
  		       blobKeyStr = blobKeyStr.trim();
    		   String attachmentStr = request.getParameter("attachment");

			   BlobKey blobKey = new BlobKey(blobKeyStr);

			   if(attachmentStr!=null && attachmentStr.trim().equals("true")){
				   BlobInfo info = infoFactory.loadBlobInfo(blobKey);
				   if(info!=null){
					   String fname = info.getFilename();
					   int ind = fname.lastIndexOf('/');
					   if(ind>0) fname = fname.substring(ind+1);
					   response.addHeader("content-disposition", "attachment; filename=" + fname);
				   }
			   }

			   blobstoreService.serve(blobKey, response);

    	   } catch (Exception e) {
    		   LOGGER.severe(e.getMessage());
               e.printStackTrace();
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println("error: "+e.getMessage());
               throw new ServletException(e);
           }
	   } 

}
