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

define(["require", "akitex/Engine", "akitex/Derivation", "akitex/Palette", "akitex/Util", "jqueryui"], function(require, Engine, Derivation, Palette, Util, jqueryUI) {
    //id: id of the item. 'main' is the default item
    //dom: $('.akit-item') of this item
    //doAnimate: true | false
    function ExerciseItem(spec) {
        var dom = spec.dom;
        var exercise = spec.exercise;
        var whenDone = spec.whenDone;
        var paletteId = spec.paletteId;
        var doAnimate = spec.doAnimate;  //will be set to false, when animation is done, to prevent future animations
        var inputHTML = 
           '<div class="akit-gen-input-widget">'
         +    '<div class="akit-input-row-1">'
         +       '<div class="akit-shortdescr"></div>'
         +       '<div class="akit-gen-hint"></div>'
         +       '<div class="akit-explanation"></div>'
         +    '</div><div class="formulaeditorpalette"/><div class="akit-input-row-2">'
         +       '<span class="akit-input-label"></span>'
         +       '<span class="akit-formula-editor-wrapper"><span class="akit-formula-editor" rows="10" cols="80"/></span>'
         +    '</div>'
         + '</div>';
 
         var archivedHTML = 
              '<div class="akit-prev-input">'
         +      '<span class="akit-result-icon"></span>'
         +      '<span class="akit-input-label"></span>'
         +      '<span class="akit-input-expression"></span>'
         +      '<span class="akit-item-msg"/>'
         +      '<span class="akit-buggy"/>'
         +    '</div>';
 
        var id = dom.attr('id');
        var template = $('.akit-input-widget', dom);
        
        function copyTemplate() {
            //insertion point: after last element
            var elm = $('.akit-gen-input-widget', dom).last();  
            var w2 = $(inputHTML);
            if (elm.length === 0) {
                $('.akit-input-widget', dom).after(w2);
            } else {
                elm.after(w2);
            }
            //copy label from widget template
            $('.akit-input-label', w2).html($('.akit-input-widget .akit-input-label', dom).html());
            Util.normalizeMathJax($('.akit-input-label', w2));
            var ee = $('.akit-input-widget script', dom);
            if (ee.length > 0) {
                var ff = $('.akit-input-label', w2);
                $('.akit-expression', ff).each(function() {
                    $(this).html($('script', this).html());//copy mathml
                });
            }
            w2.click(function(){if(!obj.isActive) exercise.showItem({itemId:id});});
            w2.addClass('active');
            obj.gen_template = w2;
        }
        
        
        var obj = {
            id: id,
            dom: dom,  //$('.akit-item') of this item
            archived: false, //if item is done, it will be archived. obj.archived is jq-element of the archived item
            successId: template.attr('onsuccess'),
            isActive: false,
            audience: exercise.audience,
            template: template,
            gen_template: null, //last (active) copy of template
            palette: null, //the palette with buttons
            isHintVisible: false,
            isVirgin: true, //false when a derivation is underway (a correct input is given)
            showHints: !(dom.attr('show-hints')==='false'),
            editor: null, //the active MathQuill editor
            status: 'uninitialized',
            init: function() {
                var _this = this;
                if (obj.status === 'uninitialized') {
                    obj.status = 'initialized';
                    
                    exercise.executeScript(dom, function() {
                        copyTemplate();
                        _this.createEditor();
                        _this.showPalette();
                        MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                        obj.gen_template.attr('solve', $('.akit-input-widget', dom).first().attr('solve'));
                    });
                }
                this.setActive();
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
                this.gen_template.remove();
            },
           //check if supplied input is correct
            //- widgetElm : $('.akit-gen-input-widget) element containing the editor
            submitInput: function(inputStr) {
                var _this = this;
                //transform supplied input in command to send to AlgebraKIT. Command is given 
                //in .akit-input-widget .akit-exercise-submit
                var submitTemplate = template.attr('submit');
                
                function callback(result) {
                    _this.clearFeedback();
                    dom.removeClass('active');
                    if (result.correct) {
                        _this.isVirgin = false;
                        if (result.done) {
                            var v = null;
                            _this.archiveInputField({exp:result.student.inputRendered, latex: inputStr, 
                                                     correct:true, done:true});
                            var exportVar = template.attr('export');
                            if (exportVar) {
                                //store result as variable, to be used in subsequent calculations
                                v = {name: exportVar, mathml: '<no MathML defined>', definition: inputStr};
                            }
                            _this.removeEditor();
                            whenDone({exportVar: v});
                        } else {
                            _this.archiveInputField({exp:result.student.inputRendered, latex: inputStr,
                                                     correct:true, done:false});
                            _this.clearInputField();
                            if (result.subDerivation) {
                                _this.gen_template.attr('lastExpression', result.student.input);
                                _this.gen_template.attr('solve', template.attr('solve'));
                            } else {
                                //this is not a subderivation
                                obj.gen_template.attr('solve', result.student.input);
                            }
                            _this.isHintVisible = false;
                        }
                    } else {
                        obj.isHintVisible = false;
                        _this.archiveInputField({exp:result.student.inputRendered, latex: inputStr,
                                                 correct:false, buggyDerivation: result.buggyDerivation});
                        _this.clearInputField();
                    }
                }
                
                Engine.checkAnswer({
                    inputExpression : inputStr,
                    orgExpression : this.gen_template.attr('solve'),
                    template : submitTemplate,
                    audience : exercise.audience,
                    answer : template.attr('answer'),
                    variables : exercise.variables,
                    mode : template.attr('mode'),
                    attributes : template.attr('solution-attributes'),
                    callback : callback
                });
            },
            
            //if this item is coupled to a hint-item, return the id of that item
            getHintId: function() {
                if(dom.attr('hint')) return dom.attr('hint');
            },
            
            getHint: function(level) {
                if (this.finished || this.isHintVisible || !this.showHints) return;
                if (!level) level = 1;
                this.isHintVisible = true;
                if(this.isVirgin) {
                    var hintElm = $('.akit-hint',dom);
                    if(hintElm.length>0) {
                        this.setHint(null, hintElm.html(), 1);
                        return;
                    }
                }
                
                var _this = this;
                var attributes = this.template.attr('solution-attributes');
                if (this.gen_template.attr('lastExpression')) {
                    Engine.getHint({
                        orgExpression : this.gen_template.attr('lastExpression'),
                        audience      : this.audience,
                        attributes    : attributes,
                        variables     : exercise.variables,
                        callback      : function(result) {
                            var derivation = new Derivation(result.step);
                            if(!derivation.isEmpty()){
                                _this.setHint(derivation, level);
                            } else {
                                Engine.getHint(_this.gen_template.attr('solve'), _this.audience, attributes, function(result) {
                                    var derivation = new Derivation(result.step);
                                    _this.setHint(derivation, level);
                                });
                            }
                        }
                    });
                } else {
                    Engine.getHint({
                        orgExpression : this.gen_template.attr('solve'),
                        audience      : this.audience,
                        attributes    : attributes,
                        variables     : exercise.variables,
                        callback      : function(result) {
                            var derivation = new Derivation(result.step);
                            _this.setHint(derivation, level);
                        }
                    });
                }
            },
            
            //display a hint. Either a derivation or html is given.
            setHint: function(derivation, html, level) {
                var jq_sd = $('.akit-shortdescr', this.gen_template).css('opacity','0');
                var jq_hint = $('.akit-gen-hint', this.gen_template).css('opacity','0');
                var jq_expl = $('.akit-explanation', this.gen_template);
                var explAvailable = false;
                if(derivation) {
                    var shortDescrAvailable = derivation.getShortDescr(jq_sd, level);
                    var hintAvailable = derivation.getHint(jq_hint, level);
                    var explAvailable = derivation.getExplanation(jq_expl);
                } else if(html) {
                    jq_sd.html(html);
                }
                jq_sd.animate({opacity:1},500);
                jq_hint.animate({opacity:1},500);
                $('.CollapseButton', jq_expl).unbind('click').click(function() {
                    jq_sd.css('display', 'block');
                    jq_hint.css('display', 'block');
                    jq_expl.css('display', 'none');
                });
                if (explAvailable) {
                    var butt = $('<span class="hint-toggle-button"> (meer) </span>');
                    jq_sd.append(butt);
                    butt.click(function() {
                        jq_sd.css('display', 'none');
                        jq_hint.css('display', 'none');
                        jq_expl.css('display', 'block');
                    });
                }
            },

            showBuggyResult: function(buggyDerivation, elm_jq) {
                var derivation = new Derivation(buggyDerivation);
                var buggyStep = derivation.getBuggyStep();
                if (buggyStep) {
                    elm_jq.html(buggyStep.shortDescr.innerHTML);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                }
            },
            
            
            clearInputField: function() {
                this.editor.revert();
                var elm = $('.akit-formula-editor-wrapper',this.gen_template);
                var html = elm.html();
                elm.empty();
                elm.html(html);
                this.createEditor();
            },
            
            archiveInputField: function(spec) {
                dom.css('display','block'); //make sure this item is not hidden anymore
                var elm = $(archivedHTML);
                this.template.before(elm);
                
                //copy label from widget template
                $('.akit-input-label', elm).html($('.akit-input-widget .akit-input-label', dom).html());
                Util.normalizeMathJax($('.akit-input-label', elm));
                var ee = $('.akit-input-widget script', dom);
                if (ee.length > 0) {
                    var ff = $('.akit-input-label', elm);
                    $('.akit-expression', ff).each(function() {
                        $(this).html($('script', this).html());//copy mathml
                    });
                }
                //var am = spec.exp.replace(/log\(\s*([^;]+)\s*;\s*([^\)]+)\s*\)/,'\\ ^($2)log $1');
                $('.akit-input-expression',elm).html(spec.exp);
                if(spec.correct) {
                    $('.akit-result-icon', elm)[0].className = 'akit-result-icon akit-icon-success';
                } else {
                    $('.akit-result-icon', elm)[0].className = 'akit-result-icon akit-icon-error';
                    $('.akit-result-icon', elm).click(function() {
                        exercise.getHint(2);
                    });
                    if(spec.buggyDerivation){
                        this.showBuggyResult(spec.buggyDerivation, $('.akit-buggy',elm));
                    }
                }
                //on click, copy the formula into the active editor
                elm.click(function(){
                    obj.editor.latex(spec.latex);
                    obj.editor.focus();
                });
                
                MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                this.archived = elm;
            },
            
            showPalette: function() {
                //hide previouw palette
                var funcPalette = 'default';
                if (!this.showHints) funcPalette = 'none';
                var palElm = $('.formulaeditorpalette', this.gen_template);
                this.palette = new Palette(palElm, this, exercise);
                this.palette.draw(paletteId, funcPalette);
                this.palette.show();
            },

            //create formula editor
            createEditor: function() {
                var _this = this;
                var templ_jq = this.gen_template;
                var input = $('.akit-formula-editor', templ_jq);
                var mathField = MathQuill.MathField(input[0], {
                    spaceBehavesLikeTab: true,
                    handlers: {
                        enter: function() {
                            var latex = mathField.latex();
                            //svar mmlStr = mathField.asciiMath();
                            _this.submitInput(latex);
                        }
                    }
                });
                this.editor = mathField;
                mathField.focus();
            },

            clearFeedback: function() {
                $('.akit-shortdescr', dom).empty();
                $('.akit-gen-hint', dom).empty();
                $('.akit-buggy', dom).empty();
                $('.akit-explanation', dom).empty();
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
