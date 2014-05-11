package nl.math4all.mathunited.configuration;

import java.util.*;
import java.io.InputStream;
import org.yaml.snakeyaml.constructor.Constructor;
import org.yaml.snakeyaml.*;
        

/**
 *
 * @author martijnslob
 */
public class Configuration {
    private Map<String, TransformationSpec> variantMap;
    private Map<String, Repository> repoMap;
    private List<String> rolesList;
    private String userfile;
    public String contentRoot;
    private String entitiesFile;
    public String mail_host;
    public String mail_smtp_port;
    public String mail_username;
    public String mail_password;
    public String admin_mail;
    private String publicData = null;
    
    private static Configuration instance = null;
    
    public static void clear() {instance = null;}
    
    public static Configuration getInstance() {
        if(instance==null) {
            Constructor constructor = new Constructor(Configuration.class);
            TypeDescription configDescription = new TypeDescription(Configuration.class);
            configDescription.putMapPropertyType("variants", String.class, TransformationSpec.class);
            configDescription.putMapPropertyType("repos", String.class, Repository.class);
            constructor.addTypeDescription(configDescription);
            Yaml yaml = new Yaml(constructor);
            
            //JavaBeanLoader<Configuration> configLoader = new JavaBeanLoader<Configuration>(Configuration.class);
            InputStream is = Configuration.class.getResourceAsStream("/configuration.yaml");
            instance = (Configuration)yaml.load(is);
            
        }
        return instance;
    }
    
    public synchronized void save() {
        Yaml yaml = new Yaml();
        String output = yaml.dump(this);
        
        System.out.println("CONFIG: " + output);
    }
    
    public Configuration() { }//should not be used 
    
    public String getPublicData() {
        if(publicData==null) {
            
        }
        return publicData;
    }
    public void setVariants(Map<String, TransformationSpec> variantMap) {this.variantMap = variantMap;}
    public Map<String, TransformationSpec> getVariants() { return variantMap; }
    public void setRepos(Map<String, Repository> repos) {this.repoMap = repos;}
    public Map<String, Repository> getRepos() {return this.repoMap;}
    public void setUserFile(String f) {this.userfile = f;}
    public String getUserFile() {return this.userfile;}
    public void setRoles(List<String> rolesList) {this.rolesList = rolesList;}
    public List<String> getRoles() {return this.rolesList;}
    public void setContentRoot(String root) {this.contentRoot = root;}
    public String getContentRoot() {return this.contentRoot;}
    public void setEntitiesFile(String file) {this.entitiesFile = file;}
    public String getEntitiesFile() {return this.entitiesFile;}
    
}
