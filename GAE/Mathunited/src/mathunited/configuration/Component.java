package mathunited.configuration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class Component {
    private final static Logger LOGGER = Logger.getLogger(Component.class.getName());
	static {LOGGER.setLevel(Level.INFO);}
	
    public List<SubComponent> subComponentList;
    String id;
    public String file;
    public String title;
    public String subTitle;
    public String methodId;
    public String number;

    public Component(String id, String file, String methodId, String title, String subTitle, List<SubComponent> subs){
        this.id = id;
        this.file = file;
        this.subComponentList = subs;
        this.title = title;
        if(subTitle == null) this.subTitle = "";
        else  this.subTitle = subTitle;
        this.methodId = methodId;
    }

    static public Map<String, Component> getComponentMap(InputSource xmlSource ) throws Exception {
        Map<String, Component> componentMap = new HashMap<String, Component>();

        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
        XPathFactory xpathFactory = XPathFactory.newInstance();
        XPath xpath = xpathFactory.newXPath();
        
        Document doc = dBuilder.parse(xmlSource);
        doc.getDocumentElement().normalize();

        XPathExpression expr = xpath.compile("//method");
        NodeList methodList = (NodeList)expr.evaluate(doc, XPathConstants.NODESET);
        for(int ii=0; ii<methodList.getLength(); ii++) {
        	Node methodNode = methodList.item(ii);
        	expr = xpath.compile("@id");
        	String methodId = (String)expr.evaluate(methodNode, XPathConstants.STRING);
        	expr = xpath.compile("components/component");
        	NodeList componentsList = (NodeList)expr.evaluate(methodNode, XPathConstants.NODESET);
            for (int jj = 0; jj < componentsList.getLength(); jj++) {
                Node componentNode = componentsList.item(jj);
                Component comp = readComponent(methodId, componentNode, xpath);
                componentMap.put(comp.id, comp);
            }
        }
        return componentMap;
    }

    static public String getAttribute(String name, Node node) {
    	NamedNodeMap map = node.getAttributes();
    	Node attrNode = map.getNamedItem(name);
    	return attrNode.getTextContent();
    }
    static public String getChild(String name, Node node) {
    	NodeList list = node.getChildNodes();
    	for(int ii=0; ii<list.getLength(); ii++) {
    		Node nn = list.item(ii);
    		if(nn.getNodeName().equals(name)) {
    			return nn.getTextContent();
    		}
    	}
    	return null;
    }
    static public Component readComponent(String methodId, Node parent, XPath xpath) throws Exception {
    	//mslo: removed the sequence of xpath-expressions, because it turns out to be too slow
    	//studiovo has more than 800 components and processing took more than one minute!
        List<SubComponent> subList = new ArrayList<SubComponent>();
 	    String compId = getAttribute("id", parent);
 	    String compFile = getAttribute("file", parent);
        String comptitle = getChild("title", parent);
        String compSubTitle = getChild("subtitle", parent);
 	    String compNumber = getAttribute("number", parent);
        Component comp = new Component(compId, compFile, methodId, comptitle, compSubTitle, subList);
        comp.number = compNumber;
        XPathExpression expr = xpath.compile("subcomponents/subcomponent");
    	NodeList subsList = (NodeList)expr.evaluate(parent, XPathConstants.NODESET);
        for (int ii = 0; ii < subsList.getLength(); ii++) {
           Node subNode = subsList.item(ii);
           String subfile = getChild("file", subNode);
           String subtitle = getChild("title", subNode);
    	   String subId = getAttribute("id", subNode);
    	   String subNumber = getAttribute("number", subNode);
           SubComponent sub = new SubComponent(subId, subtitle, subfile, subNumber);
           subList.add(sub );
        }
        return comp;
    }
    
    public String getXML() {
        StringBuilder sb = new StringBuilder();
        sb.append("<component id=\"").append(id).append("\" number=\"").append(number).append("\" file=\"").append(file).append("\"><title>").append(title).append("</title>");
        sb.append("<subtitle>").append(subTitle).append("</subtitle><subcomponents>");
        for(SubComponent sc : subComponentList) {
            sb.append("<subcomponent id=\"").append(sc.id).append("\" number=\"").append(sc.number).append("\">");
            sb.append("<title>").append(sc.title).append("</title>");
            sb.append("</subcomponent>");
        }
        sb.append("</subcomponents></component>");
        return sb.toString();
    }

	public void addToParameterMap(Map<String, String> parameterMap, String subComp) {
        parameterMap.put("component_id", id);
        parameterMap.put("component_number", number);
        parameterMap.put("component_file", file);
        parameterMap.put("component_title", title);
        parameterMap.put("component_subtitle", subTitle);
        parameterMap.put("subcomponent_count", Integer.toString(subComponentList.size()));
        int index = 0;
        String precId = "";
        for(SubComponent sc : subComponentList) {
        	if (sc.id.equals(subComp)) {
                parameterMap.put("subcomponent_number", sc.number);
                parameterMap.put("subcomponent_title", sc.title);
                parameterMap.put("subcomponent_index", Integer.toString(index));
                break;
        	}
        	else 
        		precId = sc.id;
        	index++;
        }
        String nextId = "";
        if (index + 1 < subComponentList.size())
            nextId = subComponentList.get(index + 1).id;
        parameterMap.put("subcomponent_preceding_id", precId);
        parameterMap.put("subcomponent_following_id", nextId);
        LOGGER.info(parameterMap.toString());
	}
}

