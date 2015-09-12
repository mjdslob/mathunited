// This object mirrors nl.algebrakit.wiskit.WKStep
// and represents a single step in a derivation.
// 
// Such a WKStep can contain lower lever steps in two ways:
// - the current step represents a derivation on its own, with sub-steps
//   e.g. when solving quadratic equation with  the ABC-rule, the calculation of 
//   the discriminant (D=b^2-4ac) is such a separate derivation
// - the current step contains explanation, which is built up from fragments of text
//   and expressions.
// - the current step is followed by lower-lever steps, which are hidden by default. 
//   These steps are called 'after-steps' and stored within this step.
//   e.q. the step x+2 = 5 --> x = -3 is actually a series of two steps:
//         x = 5-3  (subtract 3 from both sides)
//         x = 2    (calculate 5-3)
//   The second step is not visible by default, but the detailed derivation can be 
//   shown if the user clicks a button.
define(['jquery'], function ($) {
    var WKSTEP = {
        //static function to create WKStep from xml
        AKIT_ParseStepXML: function(stepElm) {
            var step = null;
            var outExp = null;
            var ind = 0;

            var elm = stepElm.attributes;
            var att = elm.getNamedItem("level");
            var level = -1;
            if (att) {
                level = att.value;
            }
            var visible = true;
            att = elm.getNamedItem('visible');
            if (att) {
                visible = (att.value != 'false');
            }
            var id = -1;
            att = elm.getNamedItem('id');
            if (att) {
                id = att.value;
            }
            var outExp = null;
            var shortDescr = null;
            var stepList = null;
            var afterList = null;
            var text = null;
            var name = null;

            while (ind < stepElm.childNodes.length) {
                elm = stepElm.childNodes[ind];
                if (elm.nodeType != 1) {
                    ind++;
                    continue;
                }
                switch (elm.nodeName) {
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
                        for (var ii = 0; ii < elm.childNodes.length; ii++) {
                            if (elm.childNodes[ii].nodeType == 1)
                                stepList.push(this.AKIT_ParseStepXML(elm.childNodes[ii]));
                        }
                        break;
                    case "afterList":
                        afterList = [];
                        for (var ii = 0; ii < elm.childNodes.length; ii++) {
                            if (elm.childNodes[ii].nodeType == 1)
                                afterList.push(this.AKIT_ParseStepXML(elm.childNodes[ii]));
                        }
                        break;
                    case "text":
                        text = elm;
                        break;

                }
                ind++;
            }
            return new this.Step({
                shortDescr: shortDescr,
                renderedOutExpression: outExp,
                stepList: stepList,
                afterSteps: afterList,
                text: text,
                visible: visible,
                level: level,
                name: name
            });
        },
        //constructor
        Step: function(wkstep) {
            var stepList = [];
            if(wkstep.stepList) {
                for(var ii=0; ii<wkstep.stepList.length; ii++) {
                    stepList.push( new WKSTEP.Step(wkstep.stepList[ii] ));
                }
            }
            var afterSteps = [];
            if(wkstep.afterSteps) {
                for(var ii=0; ii<wkstep.afterSteps.length; ii++) {
                    afterSteps.push( new WKSTEP.Step(wkstep.afterSteps[ii] ));
                }
            }
            var shortDescr = wkstep.heading;
            if(!shortDescr) shortDescr = wkstep.shortDescr;
            var _this = {
                afterSteps           : afterSteps,
                stepList             : stepList,
                visible              : wkstep.visible!==false,
                level                : wkstep.level,
                shortDescr           : shortDescr,
                hint                 : wkstep.hint,
                outExpression        : wkstep.outExpression,
                renderedOutExpression: wkstep.renderedOutExpression,
                text                 : wkstep.text,
                isZoomedIn           : false,
                
                zoomIn: function() {
                    var result = [];
                    var maxlevel = 0;
                    //find procedure in afterStepList with highest level.
                    for (var ii = 0; ii < this.afterSteps.length; ii++) {
                        var ps = this.afterSteps[ii];
                        if (ps.level > maxlevel) maxlevel = ps.level;
                    }
                    var current = this;
                    for (ii = 0; ii < this.afterSteps.length; ii++) {
                        ps = this.afterSteps[ii];
                        if (ps.level < maxlevel) {
                            this.addAfterStep(current, ps);
                        } else {
                            result.push(current);
                            current = ps;
                        }
                    }
                    result.push(current);
                    this.isZoomedIn = true;
                    return result;
                },
                
                zoomOut: function() {
                    this.isZoomedIn = false;  
                },

                zoomInAllowed: function() {
                    return !this.isZoomedIn && this.afterSteps.length>0
                },
                
                containsExplanation: function() {
                    return this.text!=null;
                },
                
                containsSteps: function() {
                    return this.stepList!==null && this.stepList.length>0;
                },
                
                addAfterStep: function(step) {
                    var renderedOutExpression = null;
                    if (this.visible!==false) {
                        if ((this.level === -1) || (step.level === -1))
                            return false;
                        if (this.level <= step.level)
                            return false;
                    }
                    //this step will be added to the afterSteps of this procedure or
                    //of the last procedure in this afterSteps
                    if (!this.afterSteps) {
                        this.afterSteps = [];
                    }

                    var added = false;
                    if (this.afterSteps.length > 0) {
                        var last = this.afterSteps[this.afterSteps.length - 1];
                        added = last.addAfterStep(step);
                    }
                    if (!added) {
                        this.afterSteps.push(step);
                        renderedOutExpression = step.getRenderedOutExpression();
                    }

                    return renderedOutExpression;
                },
                
                getRenderedOutExpression: function() {
                    if (!this.isZoomedIn && this.afterSteps && this.afterSteps.length > 0) {
                        var last = this.afterSteps[this.afterSteps.length - 1];
                        return last.getRenderedOutExpression();
                    }
                    return this.renderedOutExpression;
                }
            };
            return _this;
        }
    };
    return WKSTEP;
});


