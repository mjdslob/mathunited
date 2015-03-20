/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

define(["require", "akitex/Engine", "akitex/Derivation", "akitex/Palette", "akitex/Util", 
        "akitex/Cell", "jqueryui"], function(require, Engine, Derivation, Palette, Util, Cell, jqueryUI) {
    //id: id of the item. 'main' is the default item
    //dom: $('.akit-item') of this item
    //doAnimate: true | false
    function ExerciseItem(spec) {
        var Main = require('akitex/Main');
        var dom = spec.dom;
        var exercise = spec.exercise;
        var whenDone = spec.whenDone;
        var paletteId = spec.paletteId;
        var paletteVariables = spec.paletteVariables;
        var doAnimate = spec.doAnimate;  //will be set to false, when animation is done, to prevent future animations
        var activeCell = null;
        var rootCell = null;
        var tool_jq  = null; //$('.akit-input-tool')
        var inputHTML = 
           '<div class="akit-input-tool">'
         +    '<div class="formulaeditorpalette"/>'
         +       '<div class="akit-input-row-2">'
         +          '<span class="akit-input-label"></span>'
         +          '<span class="akit-formula-editor-wrapper"><span class="akit-formula-editor" rows="10" cols="80"/></span>'
         +       '</div>'
         +    '</div>'
         + '</div>';
 
        var id = dom.attr('id');
        var template = $('.akit-input-widget', dom);

        var obj = {
            id: id,
            dom: dom,  //$('.akit-item') of this item
            label : null,    //prefix for formula-editor
            archived: false, //if item is done, it will be archived. obj.archived is jq-element of the archived item
            successId: template.attr('onsuccess'),
            isActive: false,
            audience: exercise.audience,
            solutionModel: null,
            template: template,
            palette: null, //the palette with buttons
            showHints: !(dom.attr('show-hints')==='false'),
            editor: null, //the active MathQuill editor
            status: 'uninitialized',
            init: function() {
                var _this = this;
                if (obj.status === 'uninitialized') {
                    obj.status = 'initialized';
                    dom.append($('<div class="akit-cell-container"/>'));
                    tool_jq = $(inputHTML);
                    dom.append(tool_jq);
                    
                    //copy label from widget template
                    var label_jq=$('.akit-input-widget .akit-input-label', dom).clone();
                    Util.normalizeMathJax(label_jq);
                    this.label = label_jq.html();
                    
                    this.getSolutionModel(function() {
                        activeCell = new Cell({
                            key          : [],
                            answerVariable : obj.solutionModel.answerVariable,
                            lead           : obj.template.attr('solve'),
                            parent         : null,
                            parentDOM      : $('.akit-cell-container',dom).first(),
                            exerciseItem   : obj,
                            label          : this.label
                        });
                        rootCell = activeCell;
                        
                        _this.createEditor();
                        _this.showPalette();
                        MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                        _this.setActive();
                    });
                }
            },
            //get the solution model for solving the single expression that is to be simplified
            getSolutionModel: function(callback) {
                Engine.getSolutionModelFromExpr({
                    expression : this.template.attr('solve'),
                    audience : exercise.audience,
                    answer : template.attr('answer'),
                    variables : exercise.variables,
                    mode : template.attr('mode'),
                    attributes : template.attr('solution-attributes'),
                    akitVersion: spec.akitVersion,
                    callback : function(data) {
                        obj.solutionModel = data;
                        callback();
                    }
                });
            },
            setActive: function() {
                //dom.css('display','block');
                var _this = this;
                dom.addClass('active');
                this.isActive = true;
                function show() {
                    if (_this.palette) _this.palette.show();
                    _this.editor.focus();
                }
                if(doAnimate){
                    dom.hide();
                    dom.show( 'blind', {}, 500, function() {show();} );
                    doAnimate = false;
                } else {
                    show();
                }
            },
            setInactive: function() {
                this.isActive = false;
                if (this.editor) {
                    if (this.palette) this.palette.hide();
                    /*
                    if(this.editor.latex().length===0) {
                        this.editor.revert();
                        $('.akit-gen-input-widget', dom).remove();
                    }
                    */
                }
            },
            setMessage: function(msg) {
                if(this.archived) {
                    $('.akit-item-msg',this.archived).css('opacity','0').html(msg).animate({
                            opacity:1
                    },500);
                }
            }, 
            clearMessage: function() {
                    $('.akit-item-msg',this.archived).animate({
                            opacity:0
                    },500);
            },
            removeEditor: function() {
                this.setInactive();
                tool_jq.remove();
            },
           //check if supplied input is correct
            submitInput: function(inputStr) {
                //transform supplied input in command to send to AlgebraKIT. Command is given 
                //in .akit-input-widget .akit-exercise-submit
                var submitTemplate = template.attr('submit');
                function callback(result) {
                    obj.solutionState = result.state;
                    if (result.exerciseStatus==='NO_MATCH') {
                        activeCell.addInput(result.inputRendered, inputStr, null, 'NO_MATCH');
                        obj.clearInputField();
                    } else {
                        var cells = [];
                        //get the matching cells that already exist
                        for(var ii=0; ii<result.matchList.length;ii++) {
                            var key = result.matchList[ii];
                            var cell = rootCell.getCell(key, false);
                            if(cell) cells.push(cell);
                        }
                        //if none found, create the cell at highest level
                        if(cells.length===0 && result.matchList.length>0) {
                            var key = result.matchList[0];
                            var cell = rootCell.getCell(key, true);
                            cell.lead = result.inputAKIT;
                            cells.push(cell);
                        }
                        for(var ii=0; ii<cells.length; ii++) {
                            var status = result.derivationStatus;
                            cells[ii].addInput(result.inputRendered,inputStr, result.inputAKIT, status);
                        }
                        if (result.exerciseStatus==='FINISHED') {
                            activeCell.clearFeedback();
                            obj.setActiveCell( null );
                            var v = null;
                            var exportVar = template.attr('export');
                            if (exportVar) {
                                //store result as variable, to be used in subsequent calculations
                                v = {name: exportVar, mathml: '<no MathML defined>', definition: inputStr};
                            }
                            obj.removeEditor();
                            whenDone({exportVar: v});
                        } else {
                            if(result.derivationStatus==='FINISHED') obj.setActiveCell(rootCell);
                            else obj.setActiveCell( cells[0] );
                            obj.clearInputField();
                        }
                    }
                }
                
                Engine.checkAnswer({
                    expression : {expression: inputStr, template: submitTemplate, syntax: 'LATEX'},
                    model: this.solutionModel,
                    state: this.solutionState,
                    key: activeCell.key,
                    akitVersion: spec.akitVersion,
                    callback : callback
                });
            },
            
            //if this item is coupled to a hint-item, return the id of that item
            getHintId: function() {
                if(dom.attr('hint')) return dom.attr('hint');
            },
            
            getHint: function(level) {
                debugger;
                if (this.finished  || !this.showHints) return;
                if (!level) level = 1;

                if(activeCell===rootCell && activeCell.isVirgin()) {
                    var hintElm = $('.akit-hint',dom);
                    var elm = hintElm.first().clone();
                    Util.normalizeMathJax(elm);
                    if(hintElm.length>0) {
                        activeCell.setHint({
                            html: elm.html()
                        });
                        return;
                    }
                }

                Engine.getHint({
                    model : this.solutionModel,
                    state : this.solutionState,
                    cell  : activeCell,
                    akitVersion: spec.akitVersion,
                    callback      : function(result) {
                        var cell = rootCell;
                        if(result.key!==undefined) {
                            cell = rootCell.getCell(result.key,true);
                        }
                        cell.lead = result.expression;
                        obj.setActiveCell(cell);
                        activeCell=cell;
                        cell.setHint({
                            wkhint: result
                        });
                    }
                });                    
            },
            
            setActiveCell: function(cell) {
                if(activeCell) activeCell.dom.removeClass('active');
                activeCell = cell;
                if(cell) cell.dom.addClass('active');
            },
            showBuggyResult: function(buggyDerivation, elm_jq) {
                var derivation = new Derivation(buggyDerivation);
                var buggyStep = derivation.getBuggyStep();
                if (buggyStep) {
                    elm_jq.html(buggyStep.shortDescr.innerHTML);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub, elm_jq[0]]);
                }
            },
            
            
            clearInputField: function() {
                this.editor.revert();
                var elm = $('.akit-formula-editor-wrapper',this.dom);
                var html = elm.html();
                elm.empty();
                elm.html(html);
                this.createEditor();
            },
            
            showPalette: function() {
                //hide previouw palette
                var funcPalette = 'default';
                if (!this.showHints) funcPalette = 'none';
                var palElm = $('.formulaeditorpalette', tool_jq);
                this.palette = new Palette({
                    parent:  palElm,
                    item  :  this,
                    exercise: exercise,
                    id    : paletteId,
                    variables : paletteVariables
                });
                this.palette.draw(paletteId, funcPalette);
                this.palette.show();
            },

            //create formula editor
            createEditor: function() {
                var input = $('.akit-formula-editor', tool_jq);
                var mathField = MathQuill.MathField(input[0], {
                    spaceBehavesLikeTab: false,
                    handlers: {
                        enter: function() {
                            var latex = mathField.latex();
                            //svar mmlStr = mathField.asciiMath();
                            obj.submitInput(latex);
                        }
                    }
                });
                this.editor = mathField;
                mathField.focus();
            },

            clearFeedback: function(cell) {
                var key = cell.key; //list of parent definitions : ['V0_0', 'V1_0',...]
                var routeStr = '';
                for(var ii=0;ii<key.length;ii++) routeStr+=key[ii]+';';
                $('.akit-hint-container',this.dom).each(function(){
                    var hintRoute = $(this).attr('key');
                    if(hintRoute!==undefined){
                        if(hintRoute.length<routeStr.length && (routeStr.length===0 || routeStr.indexOf(hintRoute)===0)){
                            //this is a parent hint. Do not remove it
                        } else {
                            $(this).remove();
                        }
                    }
                });
                $('.akit-buggy', dom).empty();
            },
            
            focus: function() {
                this.editor.focus();
            }

        };
        return obj;
    }
    return (ExerciseItem);
}
);
