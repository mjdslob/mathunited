/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package nl.math4all.mathunited.configuration;

import org.w3c.dom.Node;

/**
 *
 * @author martijnslob
 */
public class Clipboard {
    public Node node;
    public String type;
    
    public Clipboard() {}
    public void setItem(String type, Node xmlNode) {
        this.node = xmlNode;
        this.type = type;
    }
    
}
