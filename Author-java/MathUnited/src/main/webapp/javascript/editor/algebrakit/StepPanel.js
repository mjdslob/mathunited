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

define(['jquery','algebrakit/Parser'], function($, AKITParser) {

////object: StepPanel
//step: java object containing AlgebraKIT result
//parent: the div to contain this step. This div should be added to the document
//parentStep: StepPanel object that contains this step (used for afterstep processing)
function StepPanel(step, parent, parentStepPanel, nextStep) {
   DTDSTRING = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN" "http://www.w3.org/Math/DTD/mathml2/xhtml-math11-f.dtd">';
   //state variables
   this.subStepsCreated = false;
   this.afterStepsCreated = false;
   this.explanationExpanded = false;
   this.afterStepsExpanded = false;
   this.containsExplanation = false;
   this.containsAfterSteps = false;

   this.parentStepPanel = parentStepPanel;
   this.parent = parent;//document.createElement("div");
   //this.parent.className = 'stepPanel';
   this.step   = step;

   // a step consists of two containers: one for this step and one for after steps.
   // Only one of these can be visible at the same time
   this.stepContainer = document.createElement('div');
   this.stepContainer.className = 'stepContainer';
   this.parent.appendChild(this.stepContainer);


   this.titleDiv = null;
   if(step.shortDescr) {
      this.titleDiv = document.createElement('div');
      this.titleDiv.className = 'shortDescr';
      this.stepContainer.appendChild(this.titleDiv);
      toDOM(step.shortDescr,this.titleDiv);
   }
   this.subDiv = null;
   this.nChilds = 0;
   if(step.stepList && step.stepList.length>0) {
      //add an empty div as placeholder for expansion
      this.nChilds = step.stepList.length;
      this.subDiv = document.createElement('div');
      this.subDiv.className = 'subSteps';
      this.subDiv.style.display = 'none';
      this.containsExplanation = true;
      this.stepContainer.appendChild(this.subDiv);
   }
   var outContainer = document.createElement('div');
   outContainer.className = 'outContainer';
   this.stepContainer.appendChild(outContainer);
   var outExpression = this.getRenderedOutExpression(step);
   this.outDiv = document.createElement('div');
   this.outDiv.className = 'outExpression';
   outContainer.appendChild(this.outDiv);
   this.buttonContainer = document.createElement('div');
   this.buttonContainer.className = 'buttonContainer';
   outContainer.appendChild(this.buttonContainer);
   var endElm = document.createElement('div');
   endElm.className = 'StepPanelFooterDiv';
   this.stepContainer.appendChild(endElm);

   //check if lower level steps are present
   this.afterDivContainer = null;
   if(step.afterStepList && step.afterStepList.length>0) {
      this.containsAfterSteps = true;
      this.afterDivContainer = document.createElement('div');
      this.afterDivContainer.className = 'afterStepsContainer';
      this.parent.appendChild(this.afterDivContainer);
      this.afterDivContainer.style.display = 'none';
      this.afterDivMain = document.createElement('div');
      this.afterDivMain.className = 'afterStepMain';
      this.afterDivContainer.appendChild(this.afterDivMain);
      this.afterDivSteps = document.createElement('div');
      this.afterDivSteps.className = 'afterSteps';
      this.afterDivContainer.appendChild(this.afterDivSteps);
   }

   if(outExpression) {  //do this last due to problem with IE and MathPlayer in
                        //combination with Java 5.0
      if(nextStep){
         toDOM(outExpression, this.outDiv, step.id, nextStep.id);
      } else {
         toDOM(outExpression, this.outDiv, step.id,-1);

      }
   }

   //add buttons
   if(this.outDiv.offsetHeight > this.buttonContainer.offsetHeight)
      this.buttonContainer.style.height = this.outDiv.offsetHeight+"px";
   this.createButtons();
}

StepPanel.prototype.createButtons = function() {
   if(this.outDiv) {
     var thisStepPanel = this;
     this.explainButton = document.createElement('div');
     this.explainButton.className = 'ExplainButton';
     this.explainButton.onclick = function(){thisStepPanel.showExplanation();};
     this.explainButton.onmouseover = function(){this.className = 'ExplainButtonHover';};
     this.explainButton.onmouseout = function(){this.className = 'ExplainButton';};
     this.explainButton.onmousedown = function(){this.className = 'ExplainButtonDown';};
     this.explainButton.onmouseup = function(){this.className = 'ExplainButtonHover';};
     this.collapseButton = document.createElement('div');
     this.collapseButton.className = 'CollapseButton';
     this.collapseButton.style.display='none';  //hide the collapse button
     this.collapseButton.onclick = function(){thisStepPanel.collapseExplanation();};
     this.collapseButton.onmouseover = function(){this.className = 'CollapseButtonHover';};
     this.collapseButton.onmouseout = function(){this.className = 'CollapseButton';};
     this.collapseButton.onmousedown = function(){this.className = 'CollapseButtonDown';};
     this.collapseButton.onmouseup = function(){this.className = 'CollapseButtonHover';};
     this.collapseInnerButton = document.createElement('div');
     this.collapseInnerButton.className = 'CollapseInnerButton';
     this.collapseInnerButton.style.display='none';  //hide the collapse button
     this.collapseInnerButton.onmouseover = function(){this.className = 'CollapseInnerButtonHover';};
     this.collapseInnerButton.onmouseout = function(){this.className = 'CollapseInnerButton';};
     this.collapseInnerButton.onmousedown = function(){this.className = 'CollapseInnerButtonDown';};
     this.collapseInnerButton.onmouseup = function(){this.className = 'CollapseInnerButtonHover';};
     this.collapseInnerButton.onclick = function(){thisStepPanel.collapseAfterSteps();};
     this.expandButton = document.createElement('div');
     this.expandButton.className = 'ExpandButton';
     this.expandButton.onmouseover = function(){this.className = 'ExpandButtonHover';};
     this.expandButton.onmouseout = function(){this.className = 'ExpandButton';};
     this.expandButton.onmousedown = function(){this.className = 'ExpandButtonDown';};
     this.expandButton.onmouseup = function(){this.className = 'ExpandButtonHover';};
     this.expandButton.onclick = function(){thisStepPanel.showAfterSteps();};
     this.buttonContainer.appendChild(this.explainButton);
     this.buttonContainer.appendChild(this.collapseButton);
     this.buttonContainer.appendChild(this.collapseInnerButton);
     this.buttonContainer.appendChild(this.expandButton);

     this.updateButtons();  //determine which buttons to show or hide
   }
};
StepPanel.prototype.createSubElements = function() {
   if(!this.containsExplanation) return;
    this.subDiv.style.display = 'block';
    if(this.subStepsCreated) return;
    var explanationHTML = '';
    var nprocs=0;
    var procArray = new Array();
    for(var ii=0;ii<this.nChilds;ii++) {
      var child = this.step.stepList[ii];
      if(child.text) {
         explanationHTML=explanationHTML+AKITParser.convert2HTML(child.text);
      } else {
         //create placeholder for this step
         explanationHTML=explanationHTML+'<div class="subProcStep"></div>';
         procArray[nprocs] = child;
         nprocs++;
      }
    }
    AKITParser.parseFromHTML(explanationHTML,this.subDiv);
//   doesn't work in IE:
//    var elms = this.subDiv.getElementsByClassName('subProcStep');
    var elms = new Array();
    for(var ii=0; ii<this.subDiv.childNodes.length;ii++) {
       var ee = this.subDiv.childNodes[ii];
       if(ee.nodeType===1 &&  ee.className === 'subProcStep'){
           elms.push(ee);
       }
    }
    for(var ii=0;ii<elms.length-1;ii++) {
        new StepPanel(procArray[ii],elms[ii],null, procArray[ii+1]);
    }
    if(elms.length>0) new StepPanel(procArray[ii],elms[ii]);

    this.subStepsCreated = true;
    this.isExpanded = true;
    this.isExplanationVisible = false;
}

//returns the div that contains the visual representation of this object
StepPanel.prototype.getElement = function() {
   return this.parent;
};

StepPanel.prototype.showExplanation = function() {
   if(!this.subStepsCreated) {
       this.createSubElements();
   }
   if(!this.explanationExpanded) {
      this.subDiv.style.display = 'block';
      this.explanationExpanded = true;
   }
   this.updateButtons();
};

StepPanel.prototype.showAfterSteps = function() {
   if(!this.containsAfterSteps) return;
   var afterList;
   if(!this.afterStepsCreated) {
     afterList = this.zoomIn(this.step); //get afterList from WKProcStep
     new StepPanel(afterList[0],this.afterDivMain, this);

     var nchilds = afterList.length;
     for(var ii=1;ii<nchilds;ii++) {
        new StepPanel(afterList[ii],this.afterDivSteps, null);
     }
     this.afterStepsCreated = true;
   }
   this.afterStepsExpanded = true;
   this.stepContainer.style.display = 'none';
   this.afterDivContainer.style.display = 'block';
   //
   this.updateButtons();
};

StepPanel.prototype.collapseAfterSteps = function(){
   if(this.parentStepPanel) {
       this.parentStepPanel.afterDivContainer.style.display='none';
       this.parentStepPanel.stepContainer.style.display='block';
       this.parentStepPanel.afterStepsExpanded = false;
       this.parentStepPanel.updateButtons();
       return;
   }
};

StepPanel.prototype.collapseExplanation = function(){
   if(this.explanationExpanded) {
      this.subDiv.style.display = 'none';
      this.explanationExpanded = false;
      this.updateButtons();
      return;
   }

};

//shows or hides buttons, depending on the flags in this object
StepPanel.prototype.updateButtons = function() {
   this.collapseButton.style.display='none';
   this.collapseInnerButton.style.display='none';
   this.explainButton.style.display='none';
   this.expandButton.style.display='none';
   if(this.containsExplanation) {
       if(this.explanationExpanded) {
          this.collapseButton.style.display='block';
       }
       else
          this.explainButton.style.display='block';
   }
   if(this.containsAfterSteps) {
      if(this.afterStepsExpanded) {
          this.collapseInnerButton.style.display='block';
      } else {
          this.expandButton.style.display='block';
      }
   }
   if(this.parentStepPanel) {
      this.collapseInnerButton.style.display='block';
   }
};

StepPanel.prototype.zoomIn = function(step) {
    var result = new Array();
    var maxlevel = 0;
    //find procedure in afterStepList with highest level.
    for(var ii=0;ii<step.afterStepList.length;ii++) {
        var ps = step.afterStepList[ii];
        if(ps.level>maxlevel) maxlevel = ps.level;
    }
    var afterStepList = step.afterStepList;
    var current = {
                   shortDescr:step.shortDescr,
                   renderedOutExpression: step.renderedOutExpression,
                   stepList: step.stepList,
                   level: step.level,
                   visible: step.visible,
                   parent: step,
                   afterStepList: null
                  };
    for(ii=0;ii<afterStepList.length;ii++) {
        ps = afterStepList[ii];
        if(ps.level<maxlevel) {
            this.addAfterStep(current,ps);
        } else {
            result.push(current);
            current = {
                           shortDescr:ps.shortDescr,
                           renderedOutExpression: ps.renderedOutExpression,
                           stepList: ps.stepList,
                           level: ps.level,
                           visible: ps.visible,
                           parent: step,
                           afterStepList: ps.afterStepList
                          };
        }
    }
    result.push(current);

    return result;
};

StepPanel.prototype.addAfterStep = function(thisStep, step) {
    var renderedOutExpression = null;
    if(step.visible) {
        if((step.level===-1)||(thisStep.level===-1))
            return false;
        if(thisStep.level<=step.level)
            return false;
    }
    //this step will be added to the afterStepList of this procedure or
    //of the last procedure in this afterStepList
    if(!thisStep.afterStepList) {
        thisStep.afterStepList = new Array();
    }

    var added=false;
    if(thisStep.afterStepList.length>0) {
        var last = thisStep.afterStepList[thisStep.afterStepList.length-1];
        added = this.addAfterStep(last,step);
    }
    if(!added) {
        thisStep.afterStepList.push(step);
        renderedOutExpression = step.renderedOutExpression;
    }

    return renderedOutExpression;

};

StepPanel.prototype.getRenderedOutExpression = function(step) {
    if(step.afterStepList&& step.afterStepList.length>0) {
        var last = step.afterStepList[step.afterStepList.length-1];
        return this.getRenderedOutExpression(last);
    }
    return step.renderedOutExpression;
};

//replace the contents of parent with the HTMLstring. Mathematical expressions
//are also rendered.
//NOTE: parent must be in the document and will be cleared.
function toDOM(HTMLstring, parent, thisStepId, nextStepId) {
    AKITParser.parse(HTMLstring, parent, thisStepId, nextStepId);
}


function AKIT_ParseStepXML(stepElm) {
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
        if(elm.nodeType!==1) {
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
                    if(elm.childNodes[ii].nodeType===1) stepList.push( AKIT_ParseStepXML(elm.childNodes[ii]));
                }
                break;
            case "afterList":
                afterList = [];
                for(var ii=0;ii<elm.childNodes.length;ii++) {
                    if(elm.childNodes[ii].nodeType===1) afterList.push( AKIT_ParseStepXML(elm.childNodes[ii]));
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

return (StepPanel);
});
