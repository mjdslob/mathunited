package mathunited.model;

import java.util.ArrayList;

import mathunited.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

public class StudentList extends Base {
	
	public ArrayList<Student> items = new ArrayList<Student>();
	
	/**
	 * Loads all student objects (read classes) for a student 
	 * @param repository
	 * @return
	 */
    public static StudentList load(String userId, Repository repository)
    {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   if (userId == null || userId.isEmpty())
 		   return null;
 	   
 	   Query query = new Query("Student");
 	   query.setAncestor(repoKey);
 	   query.setFilter(new FilterPredicate("userId", FilterOperator.EQUAL, userId));
 	   PreparedQuery pq = datastore.prepare(query);
 	  
 	   StudentList result = new StudentList();
 	   
  	   for (Entity entity : pq.asIterable()) {
  		   result.items.add(Student.load(entity));
 	   }
 	  
 	   return result;
    }

    public static StudentList loadForClass(String classId, Repository repository)
    {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   if (classId == null || classId.isEmpty())
 		   return null;
 	   
 	   Query query = new Query("Student");
 	   query.setAncestor(repoKey);
 	   query.setFilter(new FilterPredicate("classId", FilterOperator.EQUAL, classId));
 	   PreparedQuery pq = datastore.prepare(query);
 	  
 	   StudentList result = new StudentList();
 	   
  	   for (Entity entity : pq.asIterable()) {
  		   result.items.add(Student.load(entity));
 	   }
 	  
 	   return result;
    }

	public void save(Repository repository) throws Exception {

		for (Student item : items) {
			item.save(repository);
		}
		
	}

}
