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

define(['jquery','algebrakit/Parser','algebrakit/MMLtoAM','mathjax'], function($, AKITParser,transformer,MathJax) {

    var OBJECT = {
        AKIT_ParseStepXML : function(step) {
            var _this = this;
            var level = step.attr('level');
            if(!level) level = -1;
            var visible = (step.attr('visible')!=='false');
            var id = step.attr('id');
            if(!id) id = -1;

            var outExp = step.children('outExp').children();
            var shortDescr = step.children('shortDescr').children();
            var heading = step.children('heading').children();
            var stepList =[];
            var stepListElm = step.children('stepList').first();
            stepListElm.children('step').each(function(){
                stepList.push( _this.AKIT_ParseStepXML($(this)) );
            });
            var stepListType = stepListElm.attr('type');
            var afterList = [];
            step.children('afterList').children('step').each(function(){
                afterList.push( _this.AKIT_ParseStepXML($(this)) );
            });
            var text = step.children('text');
            var name = null;

            step = {
                id:id,
                shortDescr: shortDescr,
                heading: heading,
                renderedOutExpression: outExp,
                stepList: stepList,
                stepListType: stepListType,
                afterStepList: afterList,
                text:text,
                visible: visible,
                level:level,
                name:name
            };
            return step;
        },
        StepPanel : function(step, jq_parent, parentStepPanel, nextStep) {
            //replace the contents of parent with the HTMLstring. Mathematical expressions
            //are also rendered.
            //NOTE: parent must be in the document and will be cleared.
            function toDOM(jq_html, jq_parent, thisStepId, nextStepId) {
                AKITParser.parse(jq_html[0], jq_parent[0], thisStepId, nextStepId);
            }

            function getRenderedOutExpression(step) {
                if(step.afterStepList&& step.afterStepList.length>0) {
                    var last = step.afterStepList[step.afterStepList.length-1];
                    return getRenderedOutExpression(last);
                }
                return step.renderedOutExpression;
            }

            // a step consists of two containers: one for this step and one for after steps.
            // Only one of these can be visible at the same time
            var stepContainer = $(
                '<div class="stepContainer">'
               +'  <div class="akit-heading"/>'
               +'  <div class="subSteps"/>'
               +'  <div class="outContainer">'
               +'    <div class="outExpression"/>'
               +'    <div class="akit-inline-short-descr"/>'
               +'    <div class="buttonContainer">'
               +'       <div class="ExplainButton"/>'
               +'       <div class="CollapseButton"/>'
               +'       <div class="CollapseInnerButton"/>'
               +'       <div class="ExpandButton"/>'
               +'    </div>'
               +'  </div>'
               +'  <div class="StepPanelFooterDiv"/>'
               +'</div>'
                ).appendTo(jq_parent);
            if(stepContainer.parent('.subProcStep').attr('pos')!=='0') stepContainer.addClass('hide-head-shortdescr');
            stepContainer.addClass('substeps-'+step.stepListType);
            
            if(step.shortDescr && step.shortDescr.length>0) {
              toDOM(step.shortDescr,$('.akit-inline-short-descr', stepContainer.children('.outContainer')));
            } 

            if(step.heading && step.heading.length>0) {
              toDOM(step.heading,stepContainer.children('.akit-heading').first());
            } else {
                stepContainer.children('.akit-heading').first().remove();
            }
            
            var outExpression = getRenderedOutExpression(step);
            if(outExpression) { 
                var nextId = (nextStep?nextStep.id:-1);
                toDOM(outExpression, $('.outExpression',stepContainer), step.id, nextId);
            }

            var containsAfterSteps = false;
/*            
            if(step.afterStepList && step.afterStepList.length>0) {
                containsAfterSteps = true;
                var afterDivContainer = $(
                    '<div class="afterStepsContainer">'
                  + '  <div class="afterStepMain"/>'
                  + '  <div class="afterSteps"/>'
                  + '</div>'
                ).appendTo(jq_parent);
            }
*/
            var object = {
                subStepsCreated     : false,
                afterStepsCreated   : false,
                explanationExpanded : false,
                afterStepsExpanded  : false,
                containsExplanation : (step.stepList && step.stepList.length>0),
                containsAfterSteps  : containsAfterSteps,
                parentStepPanel     : parentStepPanel,
                stepContainer       : stepContainer,
                parent              : jq_parent,
                step                : step,
                childs              : [], //child StepPanel objects
                getRenderedOutExpression : getRenderedOutExpression,
                showExplanation     : function() {
                    if(!object.subStepsCreated) this.createSubElements();
                    stepContainer.addClass('expanded');
                    this.explanationExpanded = true;
                    stepContainer.parent('.subProcStep').prev().children('.stepContainer').addClass('hide-inline-shortdescr');
                    this.updateButtons();
                },
                collapseExplanation : function() {
                    stepContainer.removeClass('expanded');
                    this.explanationExpanded = false;
                    this.updateButtons();
                    stepContainer.parent('.subProcStep').prev().children('.stepContainer').removeClass('hide-inline-shortdescr');
                },
                collapseAfterSteps  : function() {
                    stepContainer.css('display','block');
//                    stepContainer.removeClass('visible');
                    this.updateButtons();
                },
                showAfterSteps      : function() {
                    if(!this.containsAfterSteps) return;
                    var afterList;
                    if(!this.afterStepsCreated) {
                        afterList = this.zoomIn(); //get afterList from WKProcStep
                        
                        new OBJECT.StepPanel(afterList[0],$('.afterStepMain:first', afterDivContainer), this);

                        var nchilds = afterList.length;
                        for(var ii=1;ii<nchilds;ii++) {
                           new OBJECT.StepPanel(afterList[ii],$('.afterSteps:first', afterDivContainer), null);
                        }
                        this.afterStepsCreated = true;
                    }
                    this.afterStepsExpanded = true;
                    stepContainer.css('display','none');
                    this.updateButtons();
                },
                //shows or hides buttons, depending on the flags in this object
                updateButtons       : function() {
                    var outContainer = stepContainer.children('.outContainer');
                    $('.buttonContainer div', outContainer).css('display','none');
                    if(this.containsExplanation) {
                        if(stepContainer.hasClass('expanded')) {
                           $('.CollapseButton', outContainer).css('display','block');
                        } else {
                           $('.ExplainButton', outContainer).css('display','block');
                        }
                    }
                    if(this.containsAfterSteps) {
                        $('.ExpandButton', outContainer).css('display','block');
                    }
                    if(this.parentStepPanel) {
                       $('.CollapseInnerButton', outContainer).css('display','block');
                    }
                },
                createSubElements   : function() {
                    var _this = this;
                    if(!this.containsExplanation) return;
                    if(this.subStepsCreated) return;
                    var explanationHTML = '';
                    var nprocs=0;
                    var procArray = new Array();
                    for(var ii=0;ii<this.step.stepList.length;ii++) {
                       var child = this.step.stepList[ii];
                       if(child.text.length>0) {
                          explanationHTML=explanationHTML+AKITParser.convert2HTML(child.text[0]);
                       } else {
                          //create placeholder for this step
                          explanationHTML=explanationHTML+'<div class="subProcStep" pos="'+nprocs+'"></div>';
                          procArray[nprocs] = child;
                          nprocs++;
                       }
                    }
                    var subDiv = $('.subSteps:first',stepContainer);
                    AKITParser.parseFromHTML(explanationHTML,subDiv[0]);
                    var ii=0;
                    subDiv.children('.subProcStep').each(function(){
                        var next = null;
                        if(ii<procArray.length-1) next = procArray[ii+1];
                        var child = new OBJECT.StepPanel(procArray[ii],$(this),null, next);
                        _this.childs.push(child);
                        ii++;
                    });
                    object.postprocess();

                    this.subStepsCreated = true;
                },
                zoomIn : function() {
                    var result = new Array();
                    var maxlevel = 0;
                    //find procedure in afterStepList with highest level.
                    for(var ii=0;ii<this.step.afterStepList.length;ii++) {
                        var ps = this.step.afterStepList[ii];
                        if(ps.level>maxlevel) maxlevel = ps.level;
                    }
                    var afterStepList = this.step.afterStepList;
                    var current = {
                                   shortDescr:this.step.shortDescr,
                                   renderedOutExpression: this.step.renderedOutExpression,
                                   stepList: this.step.stepList,
                                   level: this.step.level,
                                   visible: this.step.visible,
                                   parent: this.step,
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
                },
                addAfterStep : function(thisStep, step) {
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
                },
                postprocess : function() {
                    var subs = stepContainer.children('.subSteps').children();
                    if(subs.length>1) {
                        var ii;
                        for(ii=1; ii<subs.length; ii++) {
                            var thisStep = $( subs[ii] );
                            var prevStep = $( subs[ii-1] );
                            var sd = $('.stepContainer:first>.outContainer .akit-inline-short-descr', thisStep);
                            $('.stepContainer:first>.outContainer .akit-inline-short-descr',prevStep).html(
                                  sd.html() );
                        }
                        $('.stepContainer:first>.outContainer .akit-inline-short-descr',thisStep).html('');
                    }
                    
                },
                getEditorRendering : function(nextStep) {
                    var renderBox = {
                        text : '',
                        inTable : false,
                        addInline: function(expr, shortDescr ){
                            if(!this.inTable) {
                                this.text = this.text + '<table class="stepaligntable" border=0>';
                                this.inTable = true;
                            }
                            var parts = expr.split('=');
                            if(parts.length==2){
                                this.text = this.text+'<tr><td class="stepaligntable-c1">'+parts[0]+'`</td><td class="stepaligntable-c2">=</td><td class="stepaligntable-c3">`'+parts[1]+'</td><td><span class="stepaligntable-text">'+shortDescr+"</span></td></tr>";
                            } else {
                                this.text = this.text+'<tr><td class="stepaligntable-c1">'+expr+'</td><td class="stepaligntable-c2"></td><td class="stepaligntable-c3"></td><td><span class="stepaligntable-text">'+shortDescr+"</span></td></tr>";
                            }
                        },
                        addOffline: function(str) {
                            if(this.inTable) {
                                this.text = this.text + '</table>';
                                this.inTable = false;
                            }
                            this.text = this.text + str;
                        },
                        getText: function() {
                            if(this.inTable) this.text = this.text + '</table>';
                            return this.text;
                        }
                    };
                    this.renderStep(nextStep, renderBox);
                    return renderBox.getText();
                },
                renderStep : function(nextStep, renderBox) {
                    if(step.heading) {
                        var str = transformer.transform(step.heading);
                        if(str) {
                            str=str.trim();
                            if(str.length>0) {
                                renderBox.addOffline('<p>'+str+'</p>');
                            }
                        }
                        
                    }
                    
                    if(this.explanationExpanded) {
                        var procNum=0;
                        for(var ii=0; ii<step.stepList.length; ii++) {
                            var child = step.stepList[ii];
                            if(child.text.length>0) {
                                var str = transformer.transform(child.text);
                                if(str.trim().length>0) renderBox.addOffline(str);
                            } else {
                                var next = null;
                                var jj=ii+1;
                                while(jj<step.stepList.length && !step.stepList[jj].text) jj++;
                                if(jj<step.stepList.length) next = step.stepList[jj];
                                this.childs[procNum].renderStep(next, renderBox);
                                procNum++;
                            }
                        }
                    }

                    if(stepContainer.hasClass('substeps-derivation') && stepContainer.hasClass('expanded')) {
                        //do not render outExpression, to prevent printing it twice
                    } else {
                        var outExpression = getRenderedOutExpression(step);
                        
                        if(  nextStep && nextStep.shortDescr
                           &&!stepContainer.hasClass('hide-inline-shortdescr')
                          ) 
                            renderBox.addInline(transformer.transform(outExpression), transformer.transform(nextStep.shortDescr));
                        else {
                            renderBox.addInline(transformer.transform(outExpression), '');
                        }
                    }
                }
            };

            //create buttons;
            $('.ExplainButton',stepContainer).click(function() {
                object.showExplanation();
            });
            $('.CollapseButton',stepContainer).click(function() {
                object.collapseExplanation();
            });
            $('.CollapseInnerButton',stepContainer).click(function() {
                if(parentStepPanel) parentStepPanel.collapseAfterSteps();
            });
            $('.ExpandButton',stepContainer).click(function() {
                object.showAfterSteps();
            });
            object.updateButtons();
            return object;

        }
    };
    return OBJECT;
});
    