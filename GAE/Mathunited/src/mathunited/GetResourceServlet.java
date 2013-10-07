package mathunited;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.Writer;
import java.net.URLDecoder;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobInfo;
import com.google.appengine.api.blobstore.BlobInfoFactory;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Text;

public class GetResourceServlet extends HttpServlet {
        private final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
		private final BlobInfoFactory infoFactory = new BlobInfoFactory();
	    private final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

        @Override
	    public void doGet (  HttpServletRequest request, HttpServletResponse response)
	             throws ServletException, IOException {
		   
    	   try{
    		   String blobKeyStr = request.getParameter("blob-key");
			   if(blobKeyStr==null){
	               throw new Exception("Missing blob-key of the resource");
			   } else {
				   blobKeyStr = blobKeyStr.trim();
			   }
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
               e.printStackTrace();
               Writer w = response.getWriter();
               PrintWriter pw = new PrintWriter(w);
               pw.println("error: "+e.getMessage());
               throw new ServletException(e);
           }
	   } 

}
