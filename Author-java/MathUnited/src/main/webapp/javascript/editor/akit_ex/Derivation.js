/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

define(['jquery','akitex/StepPanel','akitex/Parser'], function($, StepPanel, AKITParser) {
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
            var att = elm.getNamedItem("type");
            var type;
            if(att) {
                type = att.value;
            } else type = 'normal';
            
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
            var hint = null;
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
                    case "hint":
                        hint = elm;
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
                hint: hint,
                renderedOutExpression: outExp,
                stepList: stepList,
                afterStepList: afterList,
                text:text,
                visible: visible,
                level:level,
                name:name,
                type:type
            }
            return step;
        };

        //searches currently only on first level, no inner steps
        function getFirstStep(StepNode) {
            if(StepNode) {
                if(StepNode.shortDescr!=null) return StepNode;
                if(StepNode.stepList!=null){
                    for(var ii=0; ii<StepNode.stepList.length; ii++) {
                        //if(StepNode.stepList[ii].shortDescr!=null) return StepNode.stepList[ii];
                        var ss = getFirstStep(StepNode.stepList[ii]);
                        if(ss!=null) return ss;
                    }
                }
            }
            return null;
        }
        
        function findBuggyStep(stepElm) {
            if(stepElm.type==='buggyrule') return stepElm;
            else if(stepElm.stepList) {
                for(var ii=0; ii<stepElm.stepList.length; ii++) {
                    var s = findBuggyStep(stepElm.stepList[ii]);
                    if(s) return s;
                }
            }
            return null;
        }
        
        var dom = $.parseXML(xml);
        if(dom) dom = dom.childNodes[0];
        if(dom) var step = ParseStepXML(dom);

        return {
            show: function(parent) {
                if(dom){
                    new StepPanel(step, parent[0]);
                }
            },
            getHint: function(parent,level) {
                var _this = this;
                var node = getFirstStep(step);
                if(node!==null && node.hint && node.hint.textContent) {
                    AKITParser.parse(node.hint, parent[0]);
                    return true;
                }
                return false;
            },
            getShortDescr: function(parent) {
                var node = getFirstStep(step);
                if(node===null) {
                    parent.html("Er is geen hint beschikbaar.");
                    return false;
                } else {
                    AKITParser.parse(node.shortDescr, parent[0]);
                    return true;
                }
            },
            isEmpty: function() {
                return getFirstStep(step)==null;
            },
            getExplanation: function(parent) {
                var _this = this;
                var node = getFirstStep(step);
                if(node===null) {
                    parent.html("Er is geen hint beschikbaar.");
                } else {
                    if(node.step && node.stepList.length>0){
                        var panel = new StepPanel(node, parent[0]);
                        $('.outExpression', parent).css('display', 'none');
                        panel.showExplanation();
                        return true;
                    }
                    return false;
                    /*
                    if(level===2){
                        var panel = new StepPanel(node, parent[0]);
                        $('.outExpression',parent).css('display','none');
                        panel.showExplanation();
                    } else {
                        AKITParser.parse(node.shortDescr, parent[0]);
                        var butt = $('<span class="hint-toggle-button"> (meer) </span>');
                        parent.append(butt);
                        butt.click(function() {
                           parent.empty();
                           _this.getHint(parent,2);
                        });
                    }
                    */
                }
            },
            getBuggyStep: function() {
                var buggyStep = findBuggyStep(step);
                return buggyStep;
            }
        };
        
    }
    return (Derivation);
});
