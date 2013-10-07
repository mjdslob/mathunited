package nl.math4all.mathunited.utils;

import java.io.*;
import java.nio.channels.FileChannel;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import nl.math4all.mathunited.configuration.Repository;
import org.w3c.dom.*;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
/**
 *
 * @author martijnslob
 */
public class FileManager {
    
    public static File createBackup(File file, Repository repo) throws Exception {
        int num = 0;
        String fname = file.getAbsolutePath();
        int ind = fname.lastIndexOf(".");
        String extStr = fname.substring(ind);
        fname = fname.substring(0,ind);
        fname = fname.replace(repo.path, repo.path+"/history");
        File f2 = new File(fname);
        f2.getParentFile().mkdirs();
        do {
            num++;
            String backupName = fname+"_"+num+extStr;
            f2 = new File(backupName);
        } while(f2.exists());
        copyFile(file, f2);
        return f2;
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
System.out.println("Write to file: "+fname);
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
        File backupFile = null;
        if(!file.exists()){
            file.getParentFile().mkdirs();
            file.createNewFile();
        } else {
            backupFile = createBackup(file, repo);
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
        if(backupFile!=null && getChecksum(backupFile).equals(getChecksum(file))) {
            System.out.println("Deleting backup "+backupFile.getName()+" because checksum is equal to original.");
            backupFile.delete();
        }
    }    
        
}
