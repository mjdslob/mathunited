package nl.math4all.mathunited.configuration;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.xpath.*;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;


public class Component {
    public List<SubComponent> subComponentList;
    String id;
    public String title;
    public String subTitle;
    public String methodId;
    public String number;
    public String compfile;

    public Component(String id, String methodId, String title, String compfile, String subTitle, List<SubComponent> subs){
        this.id = id;
        this.subComponentList = subs;
        this.title = title;
        this.compfile = compfile;
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

    static public Component readComponent(String methodId, Node parent, XPath xpath) throws Exception {
        List<SubComponent> subList = new ArrayList<SubComponent>();
        XPathExpression expr = xpath.compile("@id");
        String compId = (String)expr.evaluate(parent, XPathConstants.STRING);
        expr = xpath.compile("title");
        String comptitle = (String)expr.evaluate(parent, XPathConstants.STRING);
        expr = xpath.compile("@file");
        String compfile = (String)expr.evaluate(parent, XPathConstants.STRING);
        expr = xpath.compile("subtitle");
        String compSubTitle = (String)expr.evaluate(parent, XPathConstants.STRING);
        expr = xpath.compile("@number");
        String compNumber = (String)expr.evaluate(parent, XPathConstants.STRING);
        Component comp = new Component(compId, methodId, comptitle, compfile, compSubTitle, subList);
        comp.number = compNumber;
        expr = xpath.compile("subcomponents/subcomponent");
    	NodeList subsList = (NodeList)expr.evaluate(parent, XPathConstants.NODESET);
        for (int ii = 0; ii < subsList.getLength(); ii++) {
           Node subNode = subsList.item(ii);
           expr = xpath.compile("file");
           String subfile = (String)expr.evaluate(subNode, XPathConstants.STRING);
           expr = xpath.compile("title");
           String subtitle = (String)expr.evaluate(subNode, XPathConstants.STRING);
           expr = xpath.compile("@id");
           String subId = (String)expr.evaluate(subNode, XPathConstants.STRING);
           expr = xpath.compile("@number");
           String subNumber = (String)expr.evaluate(subNode, XPathConstants.STRING);
           SubComponent sub = new SubComponent(subId, subtitle, subfile, subNumber);
           subList.add(sub );
        }
        return comp;
    }
    
    public String getXML() {
        StringBuilder sb = new StringBuilder();
        sb.append("<component id=\"").append(id).append("\" number=\"").append(number).append("\" file=\"").append(compfile).append("\"><title>").append(title).append("</title>");
        sb.append("<subtitle>").append(subTitle).append("</subtitle><subcomponents>");
        for(SubComponent sc : subComponentList) {
            sb.append("<subcomponent id=\"").append(sc.id).append("\" number=\"").append(sc.number).append("\">");
            sb.append("<title>").append(sc.title).append("</title>");
            sb.append("</subcomponent>");
        }
        sb.append("</subcomponents></component>");
        return sb.toString();
    }

}

