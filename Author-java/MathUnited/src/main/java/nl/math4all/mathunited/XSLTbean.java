package nl.math4all.mathunited;


import nl.math4all.mathunited.configuration.Configuration;
import nl.math4all.mathunited.configuration.TransformationSpec;
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
import javax.xml.transform.TransformerException;
import java.util.Map;
import java.util.HashMap;

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
        tFactory.setErrorListener(new ErrorListener() {
            @Override
            public void warning(TransformerException exception) throws TransformerException {
                LOGGER.log(Level.WARNING, exception.toString());
            }

            @Override
            public void error(TransformerException exception) throws TransformerException {
                LOGGER.log(Level.SEVERE, exception.toString());
            }

            @Override
            public void fatalError(TransformerException exception) throws TransformerException {
                LOGGER.log(Level.SEVERE, exception.toString().toUpperCase());
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
        if(template==null){
            Map<String,TransformationSpec> transformationMap = Configuration.getInstance().getVariants();
            TransformationSpec spec = transformationMap.get(name);
            String path = spec.path;
            if(path==null) {
                throw new Exception("Onbekende transformatie: " + name);
            }
            InputStream is = context.getResourceAsStream(path);
            StreamSource xslSource = new StreamSource(is);
            LOGGER.log(Level.INFO, "XSLTbean: Compiling variant '" + name + "' on path " + path);
            template = tFactory.newTemplates(xslSource);
            LOGGER.log(Level.INFO, "XSLTbean: Succesfully stored template '" + name + "'.");
            templateMap.put(name, template);
        }
        return template;
    }
    
    public static void clearTemplates() {
        templateMap.clear();
    }
    
    //this method takes as input a XML source, a XSL source, and returns the output of the transformation to the servlet output stream
    public String process(Source xmlSource,
                          String variant,
                          Map<String, String> parameterMap,
                          URIResolver resolver,
                          java.io.ByteArrayOutputStream out) throws Exception {
        final StringBuilder sb = new StringBuilder();
        Templates templ = getTemplate(variant);
        Transformer transformer = templ.newTransformer();

        transformer.setErrorListener(new ErrorListener(){
            public void error(TransformerException e) {
                sb.append("<div class=\"errorDiv\">"+e.getMessageAndLocation()+"</div>");
            }
            public void fatalError(TransformerException e) {
                sb.append("<div class=\"fatalDiv\">"+e.getMessageAndLocation()+"</div>");
            }
            public void warning(TransformerException e) {
                sb.append("<div class=\"warningDiv\">"+e.getMessageAndLocation()+"</div>");
            }
        });
        for(Map.Entry<String,String> entry : parameterMap.entrySet()) {
            transformer.setParameter(entry.getKey(), entry.getValue());
        }
        transformer.setURIResolver(resolver);
        StreamResult result= new StreamResult(out);

        //Start the transformation and rendering process
        transformer.transform(xmlSource, result);  //xml->html
        return sb.toString();
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
