/* 
 * Copyright (C) 2013 Martijn Slob <m.slob@math4all.nl>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

define(['jquery','algebrakit/StepPanel','algebrakit/Parser'], function($, StepPanel, AKITParser) {
    function Derivation(xml) {
        function ParseStepXML(stepElm) {
            var step = null;
            var outExp = null;
            var ind = 0;

            var elm = stepElm.attributes;
            var att = elm.getNamedItem("level");
            var level = -1;
            if(att) {
                level = att.value;
            }
            var visible = true;
            att = elm.getNamedItem('visible');
            if(att) {
                visible = (att.value!='false');
            }
            var id = -1;
            att = elm.getNamedItem('id');
            if(att) {
                id = att.value;
            }
            var outExp = null;
            var shortDescr = null;
            var stepList = null;
            var afterList = null;
            var text = null;
            var name = null;

            while(ind<stepElm.childNodes.length){
                elm = stepElm.childNodes[ind];
                if(elm.nodeType!=1) {
                    ind++;
                    continue;
                }
                switch(elm.nodeName) {
                    case "outExp":
                        outExp = elm;
                        break;
                    case "shortDescr":
                        shortDescr = elm;
                        break;
                    case "name":
                        name = elm;
                        break;
                    case "stepList":
                        stepList = [];
                        for(var ii=0;ii<elm.childNodes.length;ii++) {
                            if(elm.childNodes[ii].nodeType==1) stepList.push( ParseStepXML(elm.childNodes[ii]));
                        }
                        break;
                    case "afterList":
                        afterList = [];
                        for(var ii=0;ii<elm.childNodes.length;ii++) {
                            if(elm.childNodes[ii].nodeType==1) afterList.push( ParseStepXML(elm.childNodes[ii]));
                        }
                        break;
                    case "text":
                        text = elm;
                        break;

                }
                ind++;
            }
            step = {
                id:id,
                shortDescr: shortDescr,
                renderedOutExpression: outExp,
                stepList: stepList,
                afterStepList: afterList,
                text:text,
                visible: visible,
                level:level,
                name:name
            };
            return step;
        };
        
        var dom = $.parseXML(xml);
        if(dom) dom = dom.childNodes[0];
        if(dom) var step = ParseStepXML(dom);

        return {
            show: function(parent) {
                if(dom){
                    new StepPanel(step, parent[0]);
                }
            }
        };
        
    }
    return (Derivation);
});
