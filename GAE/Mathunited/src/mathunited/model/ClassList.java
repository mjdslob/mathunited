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

public class ClassList extends Base {
	
	//private static final Logger log = Logger.getLogger(ClassList.class.getName());
	
	public ArrayList<Class> items = new ArrayList<Class>();
	
	/**
	 * Loads all classes from a owner 
	 * @param repository
	 * @return
	 * @throws Exception 
	 */
    public static ClassList load(String ownerId, Repository repository) throws Exception
    {
  	   if (ownerId == null || ownerId.isEmpty())
 		   throw new Exception("Missing ownerId parameter");

  	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   
 	   Query query = new Query("Class");
 	   query.setAncestor(repoKey);
 	   query.setFilter(new FilterPredicate("ownerId", FilterOperator.EQUAL, ownerId));
 	   PreparedQuery pq = datastore.prepare(query);

 	   ClassList result = new ClassList();
 	   
  	   for (Entity entity : pq.asIterable()) {
  		   Class cls = Class.load(entity);
  		   result.items.add(cls);
 	   }
 	  
 	   return result;
    }


	public void save(Repository repository) throws Exception {

		for (Class item : items) {
			item.save(repository);
		}
		
	}

	/** Loads the classes that the student subscribed to */
	public static ClassList loadForStudent(String userIdOfStudent, Repository repository) {
		
		StudentList list = StudentList.load(userIdOfStudent, repository);
		
		ClassList result = new ClassList();
		
		for (Student student : list.items) {
			Class cls = Class.load(student.classId, repository);
			result.items.add(cls);
		}
		
		return result;
		
	}
	
	public Class byId(String classId) {
		for (Class cls : items) {
			if (cls.id.equals(classId)) 
				return cls;
		}
		return null;
	}
}
