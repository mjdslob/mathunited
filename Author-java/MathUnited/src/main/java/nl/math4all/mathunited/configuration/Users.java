package nl.math4all.mathunited.configuration;

import java.util.*;
import java.io.*;
import java.io.InputStream;
import org.yaml.snakeyaml.constructor.Constructor;
import org.yaml.snakeyaml.*;
import nl.math4all.mathunited.exceptions.*;        

/**
 *
 * @author martijnslob
 */
public class Users {
    private Map<String, UserSettings> userMap;
    
    private static Users instance = null;
    
    public static void clear() {instance = null;}
    public static Users getInstance() throws ConfigException{
        try{
            if(instance==null) {
                Configuration config = Configuration.getInstance();
                Constructor constructor = new Constructor(Users.class);
                TypeDescription configDescription = new TypeDescription(Users.class);
                configDescription.putMapPropertyType("users", String.class, UserSettings.class);
                constructor.addTypeDescription(configDescription);
                Yaml yaml = new Yaml(constructor);

                //JavaBeanLoader<Configuration> configLoader = new JavaBeanLoader<Configuration>(Configuration.class);
                InputStream is = new FileInputStream(new File(config.getUserFile()));
                instance = (Users)yaml.load(is);
            }
        } catch(FileNotFoundException e){
            throw new ConfigException("Could not locate user configuration file",e);
        }
        return instance;
    }
    
    public synchronized void save() {
        Yaml yaml = new Yaml();
        String output = yaml.dump(this);
        
        System.out.println("USERS: "+output);
    }
    
    public Users() { }//should not be used 
    
    public void setUsers(Map<String, UserSettings> userList) {this.userMap = userList;}
    public Map<String, UserSettings> getUsers() {return this.userMap;}
}
