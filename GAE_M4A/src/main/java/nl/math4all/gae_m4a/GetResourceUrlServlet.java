// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GetBlobURLServlet.java

package nl.math4all.gae_m4a;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.logging.Level;
import java.util.logging.Logger;

import nl.math4all.gae_m4a.configuration.Configuration;
import nl.math4all.gae_m4a.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

public class GetResourceUrlServlet extends HttpServlet {

	private static final long serialVersionUID = -5808086102358829597L;
	private final static Logger LOGGER = Logger.getLogger(GetResourceUrlServlet.class.getName());

	public GetResourceUrlServlet()  {
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        java.io.Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);

        try   {
        	ServletContext context = getServletContext();
        	Configuration config = Configuration.getInstance(context);

            String id = request.getParameter("id");
 		   	if(id==null){
            	throw new Exception("Missing id of the resource");
 		   	}
 		   	id = java.net.URLDecoder.decode(id, "UTF-8");

 		   	String parentId = request.getParameter("parentid");
		   	if(parentId!=null){ 
				parentId = java.net.URLDecoder.decode(parentId, "UTF-8");
 		   	}
		   
 		   	String type = request.getParameter("type");
 		   	if(type==null){
            	throw new Exception("Missing type of the resource");
 		   	}
 		   	type = java.net.URLDecoder.decode(type, "UTF-8");
		   
 		   	String repo = request.getParameter("repo");
 		   	if(repo==null){
            	throw new Exception("Missing repo identifier for the resource");
 		   	}
 		   	repo = java.net.URLDecoder.decode(repo, "UTF-8");

 		   	Repository repository = config.getRepos().get(repo);
 		   	if(repository==null) {
            	throw new Exception("Onbekende repository: "+repo);
 		   	}
        	
 		   	String checksum = request.getParameter("checksum");
 		   	if(checksum==null){
            	throw new Exception("Missing checksum for the resource");
 		   	}
 		   	checksum = java.net.URLDecoder.decode(checksum, "UTF-8");

 		   	Entity entity = null;
 		   	try
 		   	{
 		   		entity = getFromDataStore(repository, parentId, id, type);
 		   	}
                        catch(EntityNotFoundException e) {
                            LOGGER.info("Could not find resource: repo="+repo+", parentId="+parentId+", id="+id+", type="+type);
                        }
 		   	
 		   	String localChecksum = "";
 		   	if (entity != null && entity.hasProperty("checksum"))
 		   		localChecksum  = (String)entity.getProperty("checksum"); 
 		   	if (localChecksum.equals(checksum))
 		   		pw.println((String)entity.getProperty("url"));
        } 
        catch(Exception e) {
            e.printStackTrace();

			pw.println("error: " + e.getMessage());
        }
    }

    private Entity getFromDataStore(Repository repository, String parentId, String id, String type) throws ServletException, EntityNotFoundException  
    {
   			Key parentKey = KeyFactory.createKey("Repository", repository.id);
   			if(parentId!=null) {
   				parentKey = KeyFactory.createKey(parentKey, "TextFile", parentId);
   			}
   			Key key = KeyFactory.createKey(parentKey, type, id);
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
   		    return datastore.get(key);
    }
}
