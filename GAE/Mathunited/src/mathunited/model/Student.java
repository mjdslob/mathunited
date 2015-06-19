package mathunited.model;

import mathunited.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

/** Student is the link between a User and a Class. A class can have multiple students and a user can have multiple Student objects */
public class Student extends Base {
	
	public long id = 0;
	public String userId;
	public String classId;
	
    public static Student load(String userId, String classId, Repository repository) {
  	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

  	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
  	   if (userId == null || userId.isEmpty())
  		   return null;
  	   
  	   Query query = new Query("Student");
  	   query.setAncestor(repoKey);
  	   query.setFilter(
  		   CompositeFilterOperator.and(
			   new FilterPredicate("userId", FilterOperator.EQUAL, userId), 
			   new FilterPredicate("classId", FilterOperator.EQUAL, classId)
		   )
       );
  	   PreparedQuery pq = datastore.prepare(query);
  	   for (Entity entity : pq.asIterable()) {
  		   return Student.load(entity); // only load first item (there should be only one anyway)
 	   }
  	   return null;
     }
     
 	public static Student load(Entity entity) {
 		Student student = new Student();
 		student.id = entity.getKey().getId();
 		student.userId = (String) entity.getProperty("userId");
 		student.classId = (String) entity.getProperty("classId");
 		return student;
 	}

 	public Key save(Repository repository) throws Exception {

 		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 		Key repoKey = KeyFactory.createKey("Repository", repository.id);
 		
 		Entity entity;
 		if (id == 0)
 			entity = new Entity("Student", repoKey);
 		else
 			entity = new Entity("Student", id, repoKey);
 		entity.setProperty("userId", userId); 
 		entity.setProperty("classId", classId);
 		
 		return datastore.put(entity);
 	}
	
	public static boolean delete(String userId, String classId, Repository repository) {
 		
 		Student student = load(userId, classId, repository);
		if (student != null)
		{
			student.delete(repository);
			return true;
		}
		return false;
	}
	
	public void delete(Repository repository) {
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
 		Key repoKey = KeyFactory.createKey("Repository", repository.id);
		Key key = KeyFactory.createKey(repoKey, "Student", id);
		datastore.delete(key);
	}
}
