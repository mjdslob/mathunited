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
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.zip.*;

/**
 *
 * @author martijnslob
 */
public class FileManager {

    public static void log(File compFile, String username, File zipFile, Repository repo) throws Exception {
        String fname = compFile.getAbsolutePath();
        fname = fname.replace(repo.getPath(),repo.getPath()+"/_history");
        File logFile = new File(fname+"/log.xml");
        if(!logFile.exists()) logFile.createNewFile();
        FileWriter fw = new FileWriter(logFile, true);//append to file
        BufferedWriter bw = new BufferedWriter(fw);
        String shortName = zipFile.getAbsolutePath();
        int ind = shortName.indexOf("_history");
        shortName = shortName.substring(ind+9);
        bw.write("<log user='"+username+"'>"+shortName+"</log>\n");
        bw.close();
    }
    
    public static boolean backupFolderExists(File subcompFolder, Repository repo) throws Exception {
        String fname = subcompFolder.getAbsolutePath();
        fname = fname.replace(repo.getPath(),repo.getPath()+"/_history");
        return new File(fname).exists();
    }
    /** creates a zip-file containing all xml files (not images or other resources) 
     *  and stores it in _history/...
     * @param subcompFolder: folder of the subcomponent
     * @param repo:
     * @return The created zip file
     */
    public static File backupSubcomponent(String name, File subcompFolder, Repository repo) throws Exception {
        String fname = subcompFolder.getAbsolutePath();
        fname = fname.replace(repo.getPath(),repo.getPath()+"/_history");
        Date date = new Date();
        SimpleDateFormat ft = new SimpleDateFormat ("yyyy.MM.dd_hh.mm.ss");
        if(name==null) {
            fname = fname+"/"+subcompFolder.getName()+"_"+ft.format(date)+".zip";
        } else {
            fname = fname+"/"+subcompFolder.getName()+"_"+name+"_"+ft.format(date)+".zip";
        }
        File fzip = new File(fname);
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
    
    public static File createBackup(File file, Repository repo) throws Exception {
        int num = 0;
        String fname = file.getAbsolutePath();
        int ind = fname.lastIndexOf(".");
        String extStr = fname.substring(ind);
        fname = fname.substring(0,ind);
        fname = fname.replace(repo.getPath(),repo.getPath()+"/_history");
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
        
}
