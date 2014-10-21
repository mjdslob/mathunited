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

define(["require", "akitex/Engine", "akitex/OpenMath", "akitex/Derivation", "akitex/Palette", "akitex/Util", "jqueryui"], function(require, Engine, OpenMath, Derivation, Palette, Util, jqueryUI) {
    function Exercise(id, dom) {
        dom = $(dom);
        dom.attr('id', 'akit-exercise-' + id);
        var palette = dom.attr('palette');
        if (!palette)  palette = 'rekenen';
        var inputHTML = 
           '<div class="akit-gen-input-widget">'
         +    '<div class="akit-input-row-1">'
         +       '<div class="akit-shortdescr"></div>'
         +       '<div class="akit-hint"></div>'
         +       '<div class="akit-explanation"></div>'
         +    '</div><div class="akit-input-row-2">'
         +       '<span class="akit-result-icon"></span>'
         +       '<span class="akit-input-label"></span>'
         +       '<span class="akit-formula-editor" rows="10" cols="80"></span>'
         +       '<span class="akit-buggy"></span>'
         +    '</div><div class="akit-input-row-3">'
         +       '<div class="akit-evaluationfeedback"></div>'
         +    '</div>'
         + '</div>';

        //check if supplied input is correct
        //- widgetElm : $('.akit-gen-input-widget) element containing the editor
        function submitInput(widgetElm, inputStr, item, ex) {
            if (ex.finished)  return;
            //transform supplied input in command to send to AlgebraKIT. Command is given 
            //in .akit-input-widget .akit-exercise-submit
            var template = $('.akit-input-widget', widgetElm.parent());
            var submitTemplate = template.attr('submit');
            Engine.checkAnswer(inputStr, submitTemplate, widgetElm.attr('solve'), template.attr('answer'), template.attr('mode'), ex.audience, template.attr('solution-attributes'), function(result) {
                if (result.correct) {
                    obj.clearFeedback();
                    $('.akit-result-icon', widgetElm)[0].className = 'akit-result-icon akit-icon-success';
                    if (result.done) {
                        var exportVar = template.attr('export');
                        if (exportVar) {
                            //store result as variable, to be used in subsequent calculations
                            var v = {name: exportVar, mathml: '<no MathML defined>', definition: inputStr};
                            ex.setVariable(v);
                        }
                        var onsuccess = item.attr('onsuccess');
                        if (onsuccess) {
                            if (onsuccess === 'main')
                                ex.showItem($('.akit-main', dom).first());
                            else
                                ex.showItem($('#' + onsuccess, ex.dom));
                        } else {
                            $('.akit-evaluationfeedback', widgetElm).html("Dit is het goede antwoord.");
                            ex.finished = true;
                            if (ex.palette) ex.palette.hide();
                        }
                    } else {
                        var newElm = createInputField(item, ex);
                        if (result.subDerivation) {
                            newElm.attr('lastExpression', result.inputExpression);
                            newElm.attr('solve', widgetElm.attr('solve'));
                        } else {
                            //this is not a subderivation
                            newElm.attr('solve', result.inputExpression);
                        }
                        item.removeAttr('hint'); //let hint button give feedback on the input
                        obj.isHintVisible = false;
                    }
                } else {
                    obj.isHintVisible = false;
                    $('.akit-result-icon', widgetElm)[0].className = 'akit-result-icon akit-icon-error';
                    $('.akit-result-icon', widgetElm).click(function() {
                        ex.getHint(2);
                    });
                    newElm = createInputField(item, ex);
                    newElm.attr('solve', widgetElm.attr('solve'));
                    $('.akit-evaluationfeedback', widgetElm).empty();
                    if (result.buggyDerivation)
                        showBuggyResult(result.buggyDerivation, widgetElm);
                }
                //derivation.show($('.debug')[0]);
            });
        }

        function  showBuggyResult(buggyDerivation, widgetElm) {
            var derivation = new Derivation(buggyDerivation);
            var buggyStep = derivation.getBuggyStep();
            if (buggyStep) {
                $('.akit-buggy', widgetElm).html(buggyStep.shortDescr.innerHTML);
                MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
            }
        }


        function createInputField(item, ex) {
            var elm = $('.akit-gen-input-widget', item).last();  //insertion point: after last element
            var w2 = $(inputHTML);
            if (elm.length === 0) {
                $('.akit-input-widget', item).after(w2);
            } else {
                elm.after(w2);
            }
            //copy label from widget template
            $('.akit-input-label', w2).html($('.akit-input-widget .akit-input-label', item).html());
            Util.normalizeMathJax($('.akit-input-label', w2));
            var ee = $('.akit-input-widget script', item);
            if (ee.length > 0) {
                var ff = $('.akit-input-label', w2);
                $('.akit-expression', ff).each(function() {
                    $(this).html($('script', this).html());//copy mathml
                });
            }
            //create formula editor
            var input = $('.akit-formula-editor', w2);
            var mathField = MathQuill.MathField(input[0], {
                handlers: {
                    enter: function() {
                        var mmlStr = mathField.asciiMath();
                        $('.akit-formula-editor', w2).before("`"+mmlStr+"`");
                        $(mathField.revert()).remove();
                        $('.akit-formula-editor', w2).remove();
                        MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                        submitInput(w2, mmlStr, item, ex);
                    }
                }
            });
            ex.setActiveEditor(mathField);
            MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
            return w2;
        }

        function setHint(derivation, level) {
            var jq_sd = $('.akit-shortdescr', obj.activeItem).last();
            var jq_hint = $('.akit-hint', obj.activeItem).last();
            var jq_expl = $('.akit-explanation', obj.activeItem).last();
            var shortDescrAvailable = derivation.getShortDescr(jq_sd, level);
            var hintAvailable = derivation.getHint(jq_hint, level);
            var explAvailable = derivation.getExplanation(jq_expl);
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
        }

        //show an item with in it the corresponding formula editor 
        function activate() {
            if (obj.status === 'uninitialized') {
                obj.status = 'initialized';
                obj.showItem($('.akit-main', obj.dom).first());//also shows editor
                var funcPalette = 'default';
                if(!obj.showHints) funcPalette = 'none';
                if (dom.next('.formulaeditorpalette').length === 0) {
                    var palElm = $('<div class="formulaeditorpalette"/>');
                    dom.prepend(palElm);
                    obj.palette = new Palette(palElm, obj);
                    obj.palette.draw(palette, funcPalette);
                }
            }
            var Main = require("akitex/Main");
            Main.setActiveExercise(obj);
        }
        
        var obj = {
            dom: dom, //equals $('.akit-exercise')
            id: id,
            template: $('.akit-input-widget', dom),
            palette: null, //the palette with buttons
            finished: false, //true when question is answered correctly
            isHintVisible: false,
            audience: dom.attr('audience'),
            showHints: !(dom.attr('show-hints')==='false'),
            exercisePrefix: dom.attr('ex-prefix'),
            activeEditor: null, //the active MathQuill editor
            activeItem: null, //$('.akit-item') containing text and optinally and editor
            status: 'uninitialized',
            items: $('.akit-item', dom),
            init: function() {
                var _this = this;
                $('.akit-item', dom).css('display', 'none');
                $('.akit-item.akit-main', dom).css('display', 'block');//note: editor is not shown yet
                if(this.template.hasClass('akit-init-open')) {
                    activate();  
                } else {
                    dom.click(function() {
                        activate();
                    });
                }
                //execute general scripts (not nested in an akit-item)
                dom.children('.akit-script').each(function() {
                    _this.executeScript($(this));
                });
            },
            showItem: function(item) {
                var _this = this;
                if ($('.akit-gen-input-widget', item).length === 0) {
                    //activate for first time: create widgets
                    this.executeScript(item, function() {
                        var firstElm = createInputField(item, _this);
                        firstElm.attr('solve', $('.akit-input-widget', item).first().attr('solve'));
                    });
                } else {
                    var span = $('.akit-formula-editor', $('.akit-gen-input-widget', item).last());
                    if (span) {
                        var editor = MathQuill.MathField(span[0]);
                        this.setActiveEditor(editor);
                    }
                }
                item.css('display', 'block');
                this.activeItem = item;
                $('.akit-item', dom).removeClass('active');
                item.addClass('active');
            },
            getHint: function(level) {
                if (this.finished || this.isHintVisible || !this.showHints)
                    return;
                if (!level) level = 1;
                this.isHintVisible = true;
                var hintId = this.activeItem.attr('hint');
                if (hintId) { //when no student input is given yet...
                    this.showItem($('#' + hintId));
                } else {     //generate hint on student input...
                    var _this = this;
                    var widget = $('.akit-gen-input-widget', this.activeItem).last();
                    var attributes = this.template.attr('solution-attributes');
                    if (widget.attr('lastExpression')) {
                        Engine.getHint(widget.attr('lastExpression'), _this.audience, attributes, function(result) {
                            var derivation = new Derivation(result.orgDerivation);
                            if(!derivation.isEmpty()){
                                setHint(derivation, level);
                            } else {
                                Engine.getHint(widget.attr('solve'), _this.audience, attributes, function(result) {
                                    var derivation = new Derivation(result.orgDerivation);
                                    setHint(derivation, level);
                                });
                            }
                        });
                    } else {
                        Engine.getHint(widget.attr('solve'), _this.audience, attributes, function(result) {
                            var derivation = new Derivation(result.orgDerivation);
                            setHint(derivation, level);
                        });
                    }
                }
            },
            setActive: function() {
//                if (this.activeEditor)
//                    this.activeEditor.focus();
                if (this.palette) this.palette.show();
            },
            setInactive: function() {
                if (this.activeEditor) {
//                    this.activeEditor.blur();
                    if (this.palette) this.palette.hide();
                    var widgetElm = $('.akit-gen-input-widget', this.dom);
                    var elm = $('.akit-formula-editor',widgetElm);
                    var mq = MathQuill.MathField(elm[0]);
                    if(mq && mq.latex().length===0) {
                        mq.revert();
                        $('.akit-gen-input-widget', this.dom).remove();
                    }
                    /*
                    if (widgetElm.length === 1) {//if there is only one editor and it is still empty, remove it
                        if ($('textarea.mathdoxformula', widgetElm).length === 0 || $('textarea.mathdoxformula', widgetElm)[0].value.length === 0) {
                            $('.akit-gen-input-widget', this.dom).remove();
                        }
                    }
                    */
                }
            },
            setActiveEditor: function(editor) {
//                if (this.activeEditor)
//                    this.activeEditor.blur();
                this.activeEditor = editor;
                editor.focus();
            },
            //execute script in item and replace all variables in this exercise (note
            //not only in this item) that got a definition
            executeScript: function(item, callback) {
                var _this = this;
                var script;
                if (item.hasClass('akit-script'))
                    script = item.text();
                else {
                    var elm = $('.akit-script', item).first();
                    if (elm.length === 0) {
                        if (callback)
                            callback();
                        return;
                    }
                    script = elm.text();
                }
                Engine.executeScript(script, this.audience, function(data) {
                    for (var ii = 0; ii < data.length; ii++)
                        _this.setVariable(data[ii]);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                    if (callback)
                        callback();
                });
            },
            setVariable: function(v) {
                $('.akit-expression[var="' + v.name + '"]', this.dom).each(function() {
                    if ($(this).attr('mode') === 'akit') {
                        $(this).replaceWith(v.definition);
                    } else {
                        $(this).html(v.mathml);
                    }
                });
                $('.akit-input-widget[solve="' + v.name + '"]', this.dom).each(function() {
                    $(this).attr('solve', v.definition);
                });
            },
            clearFeedback: function() {
                $('.akit-hint', this.activeItem).empty();
                $('.akit-explanation', this.activeItem).empty();
            }

        };
        return obj;
    }
    return (Exercise);
}
);
