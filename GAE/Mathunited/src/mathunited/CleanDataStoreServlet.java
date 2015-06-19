package mathunited;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;


public class CleanDataStoreServlet extends HttpServlet {

	private static final long serialVersionUID = 7448591788669617325L;

	@Override
    public void doGet (  HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
		   
    	try{
			response.addHeader("Content-Type", "text/html");
    		long startTime = System.nanoTime();
 		    String repo = request.getParameter("repo");
		    if(repo==null){
	              throw new Exception("Missing id of the repository");
		    }
		    repo = java.net.URLDecoder.decode(repo, "UTF-8");
 
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
   	        BlobstoreService blobstore = BlobstoreServiceFactory.getBlobstoreService();

	        Key repoKey = KeyFactory.createKey("Repository", repo);
   	       
	        @SuppressWarnings("unused")
			Entity repoEntity = datastore.get(repoKey); //throws Exception if not found (nonexistent repo)
   	        
   			Query q = new Query("TextFile").setAncestor(repoKey);
   			PreparedQuery pq = datastore.prepare(q);
   			boolean cancelled = false;
   			for (Entity result : pq.asIterable()) {

   				long currentTime = System.nanoTime();
   				long elapsed = (currentTime-startTime)/1000000000;
   				if(elapsed>30){
   	                Writer w = response.getWriter();
   	                PrintWriter pw = new PrintWriter(w);
   	                pw.println("<html><head><meta http-equiv=\"REFRESH\" content=\"0;url=http://www.mathunited.nl/clean?repo="+repo+"\"></head><body>Restarting...</body></html>");
    	            cancelled = true;
   	                break;
   				}
   				Key k = result.getKey();
	   			//clean resources
   				removeResource("image", k, datastore, blobstore);
   				removeResource("ggb", k, datastore, blobstore);
   				removeResource("cab", k, datastore, blobstore);
   				removeResource("dox", k, datastore, blobstore);
   				removeResource("movie", k, datastore, blobstore);
   				removeResource("audio", k, datastore, blobstore);

   				datastore.delete(result.getKey());
   			}   			   
   			if(!cancelled) {
   	                Writer w = response.getWriter();
   	                PrintWriter pw = new PrintWriter(w);
   	                pw.println("<html><head></head><body><h1>Finished</h1>Please delete the repo entity</body></html>");
   			}
        } catch (Exception e) {
               e.printStackTrace();
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println("error: "+e.getMessage());
               throw new ServletException(e);
        }
    } 

    public void removeResource(String type,  Key ancestorKey, DatastoreService datastore, BlobstoreService blobstore) {
			Query q = new Query(type).setAncestor(ancestorKey);
			PreparedQuery pq = datastore.prepare(q);
			for (Entity result : pq.asIterable()) {
				String blobKeyStr = (String) result.getProperty("blob-key");
				BlobKey blobKey = new BlobKey(blobKeyStr);
				blobstore.delete(blobKey);
				datastore.delete(result.getKey());
			}   			   

    }
}
