package nl.math4all.mathunited.editor;

import nl.math4all.mathunited.configuration.*;
import java.io.*;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.Map;
import java.util.logging.Level;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import nl.math4all.mathunited.resolvers.ContentResolver;
import nl.math4all.mathunited.utils.Utils;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

//mathunited.pragma-ade.nl/MathUnited/view?variant=basis&comp=m4a/xml/12hv-me0&subcomp=3&item=explore
// - fixed parameters: variant, comp (component), subcomp (subcomponent).
// - other parameters are just passed to xslt

public class GetObjectivesServlet extends HttpServlet {
    private final static Logger LOGGER = Logger.getLogger(GetObjectivesServlet.class.getName());

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        LOGGER.setLevel(Level.INFO);
    }

    @Override
    public void doGet ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/xml");
        Writer w = response.getWriter();
        PrintWriter pw = new PrintWriter(w);

        try {    
            Repository repository = Utils.getRepository(request);
            String compstr = Utils.readParameter("comp", true, request);
            
            List<String> objectiveList = readObjectives(compstr, repository);
            StringBuilder sb = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\" ?><objectives>");
            for(String obj : objectiveList) {
                sb.append(obj);
            }
            sb.append("</objectives>");
            String result = sb.toString();
            //LOGGER.log(Level.FINE, result);
            pw.println(result);
        } catch(Exception e) {
            System.out.println(Utils.echoContext(request, "ERROR"));
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
    
    private List<String> readObjectives(String compstr, Repository repository) throws Exception {
        List<String> objectiveList = new ArrayList<String>();
        Configuration config = Configuration.getInstance();
        Map<String, Component> componentMap = repository.readComponentMap();

        Component comp = componentMap.get(compstr);
        if(comp==null) throw new Exception("Cannot load component "+compstr);
        for (SubComponent ss : comp.subComponentList) {
            List<String> objectiveXMLlist = readSubcomponentObjectives(ss, compstr, repository, config);
            objectiveList.addAll(objectiveXMLlist);
        }
        
        return objectiveList;
    }
    
    private List<String> readSubcomponentObjectives(SubComponent sub, String compStr, Repository repository, Configuration config) throws Exception {
        List<String> list = new ArrayList<String>();
        String path = config.contentRoot+repository.getPath()+"/"+sub.file;
        
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
        dBuilder.setEntityResolver(ContentResolver.entityResolver);
        XPathFactory xpathFactory = XPathFactory.newInstance();
        XPath xpath = xpathFactory.newXPath();
        
        File file = new File(path);
        FileInputStream is = new FileInputStream(file);
        InputSource source = new InputSource(is);
        Document doc = dBuilder.parse(source);
        doc.getDocumentElement().normalize();

        XPathExpression expr = xpath.compile("/subcomponent/description/objectives/objective");
        NodeList objective = (NodeList)expr.evaluate(doc, XPathConstants.NODESET);
        for(int ii=0; ii<objective.getLength(); ii++) {
        	Node objNode = objective.item(ii);
        	expr = xpath.compile("@id");
        	String objId = (String)expr.evaluate(objNode, XPathConstants.STRING);
                String descr = objNode.getTextContent();
                list.add("<objective id=\""+objId+"\" subcomp=\""+sub.id+"\" comp=\""+compStr+"\">"+descr+"</objective>");
        }
        
        return list;
    }
    
    @Override
    public void doPost ( HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
    }
    
}