package nl.math4all.gae_m4a;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nl.math4all.gae_m4a.configuration.Configuration;
import nl.math4all.gae_m4a.configuration.Repository;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

public class PutResourceServlet extends HttpServlet {

    private static final long serialVersionUID = 9027963867326909149L;

    private final static Logger LOGGER = Logger.getLogger(PutResourceServlet.class.getName());
    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    ServletContext context;

    public void init(ServletConfig config) throws ServletException {
        try {
            super.init(config);
            context = getServletContext();
        } catch (Exception e) {
            LOGGER.severe((new StringBuilder("Init of PutResourceServlet failed")).append(e.getMessage()).toString());
        }
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LOGGER.setLevel(Level.INFO);
        Configuration config = Configuration.getInstance(context);

        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);

        try {
            String id = request.getParameter("id");
            if (id == null) {
                throw new Exception("Missing id of the resource");
            }
            id = java.net.URLDecoder.decode(id, "UTF-8");

            String publishId = request.getParameter("publishid");
            if (publishId == null) {
                throw new Exception("Missing publishid of the resource");
            }
            publishId = java.net.URLDecoder.decode(publishId, "UTF-8");

            String parentId = request.getParameter("parentid");
            if (parentId != null) {
                parentId = java.net.URLDecoder.decode(parentId, "UTF-8");
            }

            String type = request.getParameter("type");
            if (type == null) {
                throw new Exception("Missing type of the resource");
            }
            type = java.net.URLDecoder.decode(type, "UTF-8");

            String repo = request.getParameter("repo");
            if (repo == null) {
                throw new Exception("Missing repo identifier for the resource");
            }
            repo = java.net.URLDecoder.decode(repo, "UTF-8");

            String checksum = request.getParameter("checksum");
            if (checksum == null) {
                throw new Exception("Missing checksum identifier for the resource");
            }
            checksum = java.net.URLDecoder.decode(checksum, "UTF-8");

            Repository repository = config.getRepos().get(repo);
            if (repository == null) {
                throw new Exception("Onbekende repository: " + repo);
            }

            Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(request);
            List<BlobKey> blobKeyList = blobs.get("bin");
            BlobKey blobKey = blobKeyList.get(0);
            String blobKeyStr = blobKey.getKeyString();

            DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

            //key of resource: repository->component->resourceid
            Key repoKey = KeyFactory.createKey("Repository", repository.id);
            try {
                datastore.get(repoKey);
            } catch (EntityNotFoundException e) {
                Entity repoEntity = new Entity(repoKey);
                LOGGER.info("PutResourceServlet: creating new repository: " + repository.id);
                datastore.put(repoEntity);
            }
            Key parentKey = repoKey;
            if (parentId != null) {
                parentKey = KeyFactory.createKey(repoKey, "TextFile", parentId);
            }

            String getUrl = "/getresource?blob-key=" + blobKeyStr;
            //check if the blob already exists. In that case, update the corresponding information and remove the old blob
            Entity blobEntity = null;
            try {
                Key key = KeyFactory.createKey(parentKey, type, id);
                blobEntity = datastore.get(key);
            } catch (EntityNotFoundException e) {
            }
            if (blobEntity != null) {
                String oldPublishId = (String) blobEntity.getProperty("publishid");
                if (oldPublishId != null && oldPublishId.equals(publishId)) {
                    //this image was already published in this publish action. Remove the new image and 
                    //return a reference to the old image
                    blobstoreService.delete(blobKey);
                    blobKeyStr = (String) blobEntity.getProperty("blob-key");
                    getUrl = "/getresource?blob-key=" + blobKeyStr;

                } else {
                    // remove old resource from BlobStore first, then update entity
                    String oldBlobKeyStr = (String) blobEntity.getProperty("blob-key");
                    BlobKey oldBlobKey = new BlobKey(oldBlobKeyStr);
                    blobstoreService.delete(oldBlobKey);
                }
            } else {
                //add new Entity
                blobEntity = new Entity(type, id, parentKey);
            }
            blobEntity.setProperty("blob-key", blobKeyStr);
            blobEntity.setProperty("url", getUrl);
            blobEntity.setProperty("date", new Date());
            blobEntity.setProperty("publishid", publishId);
            blobEntity.setProperty("checksum", checksum);
            datastore.put(blobEntity);

            pw.println(getUrl);

        } catch (Exception e) {
            e.printStackTrace();
            pw.println("error: " + e.getMessage());
            throw new ServletException(e);
        }
    }

}
