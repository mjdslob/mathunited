package nl.math4all.gae_m4a.model;

import java.util.Date;

import nl.math4all.gae_m4a.configuration.Repository;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

public class User extends Base
{
	public enum UserRole { Student, Teacher };
	
	public String id;
	public String firstName;
	public String lastNamePrefix;
	public String lastName;
	public String email;
	public UserRole role;
	public String schoolcode;
	public Date registrationDate = new Date();
	
    public static User load(String userId, Repository repository)
    {
 	   DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

 	   Key repoKey = KeyFactory.createKey("Repository", repository.id);
 	   if (userId == null || userId.isEmpty())
 		   return null;
 	   
 	   Key key = KeyFactory.createKey(repoKey, "User", userId);
 	   try {
 		   Entity entity = datastore.get(key);
 		   return load(entity);
 	   }
 	   catch (EntityNotFoundException ex) {
 		   return null;
 	   }
    }
    
    public static User load(Entity entity) {
    	
 	   User user = new User();
 	   user.id = entity.getKey().getName();
 	   user.firstName = (String)entity.getProperty("firstName");
 	   user.lastNamePrefix = (String)entity.getProperty("lastNamePrefix");
 	   user.lastName = (String)entity.getProperty("lastName");
 	   user.email= (String)entity.getProperty("email");
 	   user.role = UserRole.valueOf((String)entity.getProperty("role"));
 	   user.schoolcode = (String)entity.getProperty("schoolcode"); 
 	   Date dateProp = (Date)entity.getProperty("registrationDate");
 	   user.registrationDate = dateProp;
 	   return user;
    	
    }


	public Key save(Repository repository) throws Exception {

		if (id == null || id.isEmpty())
			throw new Exception("id cannot be empty when saving objects of type User");
		
		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

		Key repoKey = KeyFactory.createKey("Repository", repository.id);
		
		Entity entity = new Entity("User", id, repoKey);
		entity.setProperty("firstName", firstName);
		entity.setProperty("lastNamePrefix", lastNamePrefix);
		entity.setProperty("lastName", lastName);
		entity.setProperty("email", email);
		entity.setProperty("role", role.name());
		entity.setProperty("schoolcode", schoolcode);
		entity.setProperty("registrationDate", registrationDate);
		
		return datastore.put(entity);
	}
	
	public boolean isRegistered() {
		return firstName != null && !firstName.isEmpty();
	}

	public boolean isTeacher() {
		return isRegistered() && role == UserRole.Teacher;
	}
	
	public String fullName() {
		String result = firstName;
		if (lastNamePrefix != null && !lastNamePrefix.equals(""))
			result += " " + lastNamePrefix;
		result += " " + lastName;
		return result;
	}
}
