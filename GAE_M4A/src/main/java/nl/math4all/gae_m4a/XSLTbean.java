package nl.math4all.gae_m4a;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletContext;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import nl.math4all.gae_m4a.configuration.TransformationSpec;

/**
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
    
    private Map<String,TransformationSpec> transformationMap;
    
    //the constructor simply gets a new TransformerFactory instance
    public XSLTbean(ServletContext ctxt, Map<String,TransformationSpec> transformationMap) throws Exception {
        LOGGER.setLevel(Level.INFO);
        context = ctxt;
        this.transformationMap = transformationMap;
    }

    public static Templates getTemplate(String name, Map<String,TransformationSpec> transformationMap) throws Exception{
        Templates template = templateMap.get(name);
    	try{
	        if(template==null){
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

        Templates templ = getTemplate(variant, transformationMap);
        Transformer transformer = templ.newTransformer();
LOGGER.info("P-2");

        for(Map.Entry<String,String> entry : parameterMap.entrySet()) {
            transformer.setParameter(entry.getKey(), entry.getValue());
        }
        transformer.setURIResolver(resolver);
        StreamResult result= new StreamResult(out);
            
        //Start the transformation and rendering process
        transformer.transform(xmlSource, result);  //xml->html
LOGGER.info("P-3");
        
    }

    //this method takes as input a XML source, a XSL source, and returns the output of the transformation to the servlet output stream
    public org.w3c.dom.Node processToDOM(Source xmlSource,
                          String variant,
                          Map<String, String> parameterMap,
                          URIResolver resolver,
                          Map<String,TransformationSpec> transformationMap) throws Exception{
        Templates templ = getTemplate(variant, transformationMap);
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
