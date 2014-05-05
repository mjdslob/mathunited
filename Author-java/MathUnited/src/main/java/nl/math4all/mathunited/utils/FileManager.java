package nl.math4all.mathunited.utils;

import java.io.*;
import java.nio.channels.FileChannel;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import nl.math4all.mathunited.configuration.*;
import org.w3c.dom.*;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.zip.*;
import nl.math4all.mathunited.editor.PostContentServlet;
//import javax.security.auth.login.Configuration;

/**
 *
 * @author martijnslob
 */
public class FileManager {
    private final static Logger LOGGER = Logger.getLogger(FileManager.class.getName());
    static {
        LOGGER.setLevel(Level.INFO);
    }

    private static File getBackupFolder(String subFolder, Repository repo) {
        Configuration config = Configuration.getInstance();
        String fname = config.getContentRoot();
        String repoPath = repo.getPath();
        if(repoPath.isEmpty()) {
            fname = fname+"_history/";
        } else {
            fname = fname+repoPath+"/_history/";
        }
        fname = fname + subFolder;
        LOGGER.log(Level.FINE, "getBackupFolder: subFolder={0}, result={1}", new Object[]{subFolder, fname});
        return new File(fname);
    }
    private static File getSubcompFolder(String subFolder, Repository repo) {
        Configuration config = Configuration.getInstance();
        String fname = config.getContentRoot();
        String repoPath = repo.getPath();
        if(!repoPath.isEmpty()) {
            fname = fname+repoPath+"/";
        }
        fname = fname + subFolder;
        LOGGER.log(Level.FINE, "getSubcompFolder: subFolder={0}, result={1}", new Object[]{subFolder, fname});
        return new File(fname);
    }
    
    public static void log(String subFolder, String username, File zipFile, Repository repo) throws Exception {
        File compFile = getBackupFolder(subFolder, repo).getParentFile();
        File logFile = new File(compFile, "log.xml");
        if(!logFile.exists()) logFile.createNewFile();
        FileWriter fw = new FileWriter(logFile, true);//append to file
        BufferedWriter bw = new BufferedWriter(fw);
        String shortName = zipFile.getAbsolutePath();
        int ind = shortName.indexOf("_history");
        shortName = shortName.substring(ind+9);
        bw.write("<log user='"+username+"'>"+shortName+"</log>\n");
        bw.close();
    }
    
    public static boolean backupFolderExists(String subFolder, Repository repo) throws Exception {
        File subcompFolder = getBackupFolder(subFolder, repo);
        return subcompFolder.exists();
    }
    /** creates a zip-file containing all xml files (not images or other resources) 
     *  and stores it in _history/...
     * @param subcompFolder: folder of the subcomponent
     * @param repo:
     * @return The created zip file
     */
    public static File backupSubcomponent(String name, String subFolder, Repository repo) throws Exception {
        File backupFolder = getBackupFolder(subFolder, repo);
        File subcompFolder = getSubcompFolder(subFolder, repo);
        Date date = new Date();
        SimpleDateFormat ft = new SimpleDateFormat ("yyyy.MM.dd_hh.mm.ss");
        int index = subFolder.lastIndexOf("/");
        String fname = subFolder.substring(index+1);
        if(name==null) {
            fname = fname+"_"+ft.format(date)+".zip";
        } else {
            fname = fname+"_"+name+"_"+ft.format(date)+".zip";
        }
        File fzip = new File(backupFolder, fname);
        LOGGER.log(Level.FINE, "Creating log file {0}", new Object[]{fzip.getAbsoluteFile()});
        fzip.getParentFile().mkdirs();

        FileOutputStream fos = new FileOutputStream(fzip);
        ZipOutputStream zos = new ZipOutputStream(fos);
        zos.setLevel(9);//level - the compression level (0-9)

        File f2[] = subcompFolder.listFiles();
        for(File fentry: f2){
            String nameStr = fentry.getName();
            int ind = nameStr.lastIndexOf('.');
            //only add xml files
            if(ind>0 && nameStr.substring(ind+1).equals("xml") ) {
                String entryName = fentry.getName();
                ZipEntry ze= new ZipEntry(entryName);
                zos.putNextEntry(ze);
                FileInputStream in = new FileInputStream(fentry);
                int len;
                byte buffer[] = new byte[1024];
                while ((len = in.read(buffer)) > 0) {
                    zos.write(buffer, 0, len);
                }
                in.close();
                zos.closeEntry();
            }
        }
        zos.close();
        
        return fzip;
    }
    
    public static void copyFile(File sourceFile, File destFile) throws IOException {
        if(!destFile.exists()) {
            destFile.createNewFile();
        }

        FileChannel source = null;
        FileChannel destination = null;

        try {
            source = new FileInputStream(sourceFile).getChannel();
            destination = new FileOutputStream(destFile).getChannel();
            destination.transferFrom(source, 0, source.size());
        }
        finally {
            if(source != null) {
                source.close();
            }
            if(destination != null) {
                destination.close();
            }
        }
    }

    public static String getChecksum(File filename) throws Exception {
       InputStream fis =  new FileInputStream(filename);

       byte[] buffer = new byte[1024];
       java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
       int numRead;

       do {
           numRead = fis.read(buffer);
           if (numRead > 0) {
               md.update(buffer, 0, numRead);
           }
       } while (numRead != -1);

       fis.close();
       byte[] array = md.digest();
       StringBuilder sb = new StringBuilder();
       for (int i = 0; i < array.length; ++i) {
          sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
       }
       return sb.toString();
    }
    
    static public void writeToFile(String fname, Node node, Repository repo) throws Exception {        
        DOMImplementationRegistry registry = DOMImplementationRegistry.newInstance();
        DOMImplementationLS impl = (DOMImplementationLS)registry.getDOMImplementation("LS");
        
        LSSerializer writer = impl.createLSSerializer();
        DOMConfiguration config = writer.getDomConfig();
        config.setParameter("format-pretty-print", true);
        config.setParameter("error-handler", new DOMErrorHandler(){
           public boolean handleError(DOMError error) {
               System.out.println(error.getMessage());
               return true;
           }
        });
        //put node in a new document, so processing instruction etc can be set
        Document newDoc = null;
        if(node.getNodeName().equals("#document")){

        } else {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            newDoc = db.newDocument();
            newDoc.appendChild(newDoc.createProcessingInstruction("context-directive", "job ctxfile ../m4all-leertaak.ctx"));
            newDoc.appendChild(newDoc.importNode(node,true));
            
        }
        
        LSOutput output = impl.createLSOutput();
        File file = new File(fname);
        if(!file.exists()){
            file.getParentFile().mkdirs();
            file.createNewFile();
        }
        if(file.exists()) {
            FileOutputStream fos = new FileOutputStream(file);
            OutputStreamWriter fwriter = new OutputStreamWriter(fos, "UTF-8");
            output.setCharacterStream(fwriter);
            if(newDoc!=null)
                writer.write(newDoc, output);
            else
                writer.write(node, output);
            fwriter.close();
        }
    }    
        
    static public String serializeXML(Node node) throws Exception {
        DOMImplementationRegistry registry = DOMImplementationRegistry.newInstance();
        DOMImplementationLS impl = (DOMImplementationLS)registry.getDOMImplementation("LS");
        LSSerializer writer = impl.createLSSerializer();
        DOMConfiguration config = writer.getDomConfig();
        config.setParameter("format-pretty-print", true);
        String result = writer.writeToString(node);
        return result;
    }
}
