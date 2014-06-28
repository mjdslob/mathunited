package mathunited.model;

import java.util.Date;

import mathunited.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Text;

public class Class extends Base {
	
	public String id;
	public String ownerId;
	public Date registrationDate = new Date();
	
    public static Class load(String id, Repository repository) {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   if (id == null || id.isEmpty())
 		   return null;
 	   
 	   Key key = KeyFactory.createKey(repoKey, "Class", id);
 	   try {
 		   Entity entity = datastore.get(key);
 	 	   return load(entity);
 	   }
 	   catch (EntityNotFoundException ex) {
 		   return null;
 	   }
    }
    
	public static Class load(Entity entity) {
		Class cls = new Class();
		cls.id = entity.getKey().getName();
		cls.ownerId = (String) entity.getProperty("ownerId");
		cls.registrationDate = (Date) entity.getProperty("registrationDate");
		return cls;
	}

	public Key save(Repository repository) throws Exception {

		if (id == null || id.isEmpty())
			throw new Exception("id cannot be empty when saving objects of type User");
		
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		Key repoKey = KeyFactory.createKey("Repository", repository.id);
		
		Entity entity = new Entity("Class", id, repoKey);
		entity.setProperty("ownerId", ownerId);
		entity.setProperty("registrationDate", registrationDate);
		
		return datastore.put(entity);
	}
}
