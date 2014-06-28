package mathunited.model;

import java.util.ArrayList;

import mathunited.configuration.Repository;
import mathunited.model.User.UserRole;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

public class UserList extends Base {
	
	public ArrayList<User> items = new ArrayList<User>();
	
    public static UserList loadTeachers(String schoolcode, Repository repository)
    {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   
 	   Query query = new Query("User");
 	   query.setAncestor(repoKey);
 	   query.setFilter(new FilterPredicate("role", FilterOperator.EQUAL, UserRole.Teacher.name()));
 	   PreparedQuery pq = datastore.prepare(query);
 	  
 	   UserList result = new UserList();
 	   
  	   for (Entity entity : pq.asIterable()) {
  		   result.items.add(User.load(entity));
 	   }
 	  
 	   return result;
    }

    public static UserList load(Repository repository)
    {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   
 	   Query query = new Query("User");
 	   query.setAncestor(repoKey);
 	   PreparedQuery pq = datastore.prepare(query);
 	  
 	   UserList result = new UserList();
 	   
  	   for (Entity entity : pq.asIterable()) {
  		   result.items.add(User.load(entity));
 	   }
 	  
 	   return result;
    }
    
	public void save(Repository repository) throws Exception {

		for (User item : items) {
			item.save(repository);
		}
		
	}

}
