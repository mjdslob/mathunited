package mathunited;


import javax.servlet.ServletContext;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.Templates;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.dom.DOMResult;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.io.*;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import java.util.Map;
import java.util.HashMap;
import mathunited.configuration.TransformationSpec;
import mathunited.configuration.Configuration;

/**
 *
 * @author martijn
 */
public class XSLTbean {
    private static ServletContext context;
    private static final String XSLTroot = "/xslt/";
    private final static Logger LOGGER = Logger.getLogger(XSLTbean.class.getName());
    private static Map<String, Templates> templateMap = new HashMap<String, Templates>();
    private static TransformerFactory tFactory = TransformerFactory.newInstance();
    static {
        tFactory.setURIResolver(new URIResolver() {
            public StreamSource resolve(String href, String base){
                InputStream xmlStream = context.getResourceAsStream(XSLTroot+href);
                return new StreamSource(xmlStream);
            }
        });
    }
    

    //the constructor simply gets a new TransformerFactory instance
    public XSLTbean(ServletContext ctxt) throws Exception {
        LOGGER.setLevel(Level.INFO);
        context = ctxt;
    }

    public static Templates getTemplate(String name) throws Exception{
        Templates template = templateMap.get(name);
    	try{
	        if(template==null){
	            Map<String,TransformationSpec> transformationMap = Configuration.getInstance().getVariants();
	            TransformationSpec spec = transformationMap.get(name);
	            String path = spec.path;
	            if(path==null) throw new Exception("Onbekende transformatie: "+name);
	            InputStream is = context.getResourceAsStream(path);
	            StreamSource xslSource = new StreamSource(is);
	            System.out.println("XSLTbean: Compiling variant "+name);
	            template = tFactory.newTemplates(xslSource);
	            templateMap.put(name, template);
	        }
    	} catch(Exception e) {
    		throw new Exception("Error when trying to compile xslt-script "+name,e);
    	}
        return template;
    }
    
    public static void clearTemplates() {
        templateMap.clear();
    }
/*
    public static void setTemplates(Map<String, String> variantMap, boolean forced, ServletContext ctxt) throws Exception{
        try {
            context = ctxt;
            TransformerFactory tFactory;
            Map<String, Templates> tempMap = new HashMap<String, Templates>();
            tFactory = TransformerFactory.newInstance();
            tFactory.setURIResolver(new URIResolver() {
                public StreamSource resolve(String href, String base){
                    InputStream xmlStream = context.getResourceAsStream(XSLTroot+href);
                    if(xmlStream==null) {
                    	LOGGER.log(Level.SEVERE, "Could not locate XSLT file "+XSLTroot+href);
                    }
                    return new StreamSource(xmlStream);
                }
            });
            boolean changed = false;
            for(Map.Entry<String,String> entry:variantMap.entrySet()) {
                String key = entry.getKey();
                String val = entry.getValue();
                if(forced || templateMap.get(key)==null){
                    InputStream is = context.getResourceAsStream(val);
                    if(is==null) {
                    	LOGGER.log(Level.SEVERE, "Could not locate XSLT file "+val);
                    }
                    StreamSource xslSource = new StreamSource(is);
                    Templates templ = tFactory.newTemplates(xslSource);
                    tempMap.put(key, templ);
                    changed = true;
                } else {
                    tempMap.put(key, templateMap.get(key));
                }
                if(changed) templateMap = tempMap;
            }
        }catch(TransformerConfigurationException e){
            e.printStackTrace();
            throw e;
        }
    }
*/
    
    //this method takes as input a XML source, a XSL source, and returns the output of the transformation to the servlet output stream
    public void process(Source xmlSource,
                          String variant,
                          Map<String, String> parameterMap,
                          URIResolver resolver,
                          java.io.ByteArrayOutputStream out) throws Exception {

        Templates templ = getTemplate(variant);
        Transformer transformer = templ.newTransformer();

        for(Map.Entry<String,String> entry : parameterMap.entrySet()) {
            transformer.setParameter(entry.getKey(), entry.getValue());
        }
        transformer.setURIResolver(resolver);
        StreamResult result= new StreamResult(out);
            
        //Start the transformation and rendering process
        transformer.transform(xmlSource, result);  //xml->html
    }

    //this method takes as input a XML source, a XSL source, and returns the output of the transformation to the servlet output stream
    public org.w3c.dom.Node processToDOM(Source xmlSource,
                          String variant,
                          Map<String, String> parameterMap,
                          URIResolver resolver) throws Exception{
        Templates templ = getTemplate(variant);
        Transformer transformer = templ.newTransformer();
        for(Map.Entry<String,String> entry : parameterMap.entrySet()) {
            transformer.setParameter(entry.getKey(), entry.getValue());
        }
        transformer.setURIResolver(resolver);

        DOMResult result= new DOMResult();

        //Start the transformation and rendering process
        transformer.transform(xmlSource, result);  //transform to xml DOM
        return result.getNode();//.getOwnerDocument().getDocumentElement();
    }    
}
