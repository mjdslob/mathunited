/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

define(["require", "akitex/Engine", "akitex/ExerciseItem"], function(require, Engine, ExerciseItem) {
    //spec:
    // - id 
    // - dom : $('.akit-exercise')
    // - onFinished : callback 
    function Exercise(spec) {
        var id = spec.id;
        var dom = $(spec.dom);
        var akitVersion = dom.attr('akit-version');
        var orgDom = dom.html(); //store original state for revert()
        dom.attr('id', 'akit-exercise-' + id);
        var paletteId = dom.attr('palette');
        var paletteVariableSpec = dom.attr('palette-variables');
        if(paletteVariableSpec) {
            paletteVariableSpec = paletteVariableSpec.split(',');
            if(paletteVariableSpec.length>2) paletteVariableSpec = [paletteVariableSpec[0],paletteVariableSpec[1]];
            else if(paletteVariableSpec.length===1) paletteVariableSpec=[paletteVariableSpec[0],'y'];
        } else {
            paletteVariableSpec = ['x','y'];
        }
        
        
        if (!paletteId)  paletteId = 'rekenen';

        var obj = {
            dom: dom, //equals $('.akit-exercise')
            id: id,
            isRandomized : dom.attr('randomized')==='true', //when true, you can generate clones by re-initializing
            variables: [],  //defined variables in this exercise v[name] ={mathml, definition};
            audience: dom.attr('audience'),
            finished: false, //true when question is answered correctly
            status: 'uninitialized',
            items: $('.akit-item', dom),
            activeItem: null, //$('.akit-item') containing text and optionally and editor
            init: function() {
                var _this = this;
                //show an item with in it the corresponding formula editor 
                function create() {
                    if (_this.status === 'uninitialized') {
                        _this.status = 'initialized';
                        _this.showItem({itemId:'main'});
                    }
                    var Main = require("akitex/Main");
                    Main.setActiveExercise(_this);
                }

                //execute general scripts (not nested in an akit-item)
                _this.executeScript(dom.children('.akit-script').first(), function() {
                    if(_this.dom.hasClass('akit-init-open')) {create();} 
                    else  _this.dom.click(function() { create(); });
                });
            },
            //an item is a single question. An Exercise can contain multiple items.
            //spec =
            //  - itemId  : id of the item to show
            //  - relativeItem : item after/before to place this item
            //  - placeBefore: true to place new item before item 'relativeId'
            //  - doAnimate: true | false
            showItem: function(spec) {
                var _this = this, item_jq;
                var item = this.items[spec.itemId];
                if(this.activeItem && this.activeItem.id!==spec.itemId) this.activeItem.setInactive();
                if(item) {
                    item.setActive();
                } else {
                    //create item
                    if(spec.itemId==='main'){
                        item_jq = $('.akit-main',dom);
                    } else {
                        item_jq = $('#'+spec.itemId);
                    }
                    if(spec.relativeItem && this.activeItem) {
                        if(spec.placeBefore) this.activeItem.dom.before(item_jq);
                        else this.activeItem.dom.after(item_jq);
                    }
                    item = new ExerciseItem({
                        dom: item_jq,
                        exercise: _this,
                        paletteId: paletteId,
                        paletteVariables: paletteVariableSpec,
                        doAnimate: spec.doAnimate,
                        akitVersion: akitVersion,
                        whenDone: function(v){
                            if(v && v.exportVar) _this.setVariable(v.exportVar);
                            var s = item_jq.attr('onsuccess');
                            var ai = _this.activeItem;
                            if(s){
                                ai.setMessage('Dit is het goede antwoord');
                                setTimeout(function() {ai.clearMessage();},5000);
                                setTimeout(function(){
                                    if(s) _this.showItem({itemId:s, relativeItem: _this.activeItem, placeBefore:false, doAnimate:true});
                                },1000);
                            } else {
                                ai.setMessage('Goed. Je hebt de opgave afgerond.');
                                _this.setFinished();
                            }
                        }
                    });
                    _this.items[spec.itemId]=item;
                    item.init();
                }
                this.activeItem = item;
            },
            setActive: function() {
                if(this.activeItem) this.activeItem.setActive();
                dom.addClass('active');
            },
            setInactive: function() {
                if (this.activeItem) this.activeItem.setInactive();
                dom.removeClass('active');
            },
            setFinished: function() {
                this.status = 'finished';
                //dom.append('<div class="akit-post-message">Je hebt de opgave afgerond.</div>')
                if(spec.onFinished) spec.onFinished();
            },
            //remove the exercise and restore the original dom
            revert: function() {
                dom.html(orgDom);
            },
            getHint: function() {
                if(this.activeItem) {
                    var hintId = this.activeItem.getHintId();
                    if(this.activeItem.isVirgin && hintId) {
                        var hintItem = this.items[hintId];
                        if(!hintItem || hintItem.archived===false) {
                            this.activeItem.setInactive();
                            this.showItem({itemId:this.activeItem.getHintId(), relativeItem: this.activeItem, placeBefore:true, doAnimate:true});
                        } else this.activeItem.getHint();
                    }  else this.activeItem.getHint();
                }
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
                        if (callback) callback();
                        return;
                    }
                    script = elm.text();
                }
                Engine.executeScript(script, this.audience, function(data) {
                    for (var ii = 0; ii < data.length; ii++)
                        _this.setVariable(data[ii]);
                    MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                    if (callback) callback();
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
                this.variables[v.name]={mathml:v.mathml, definition:v.definition};
            }
        };
        return obj;
    }
    return (Exercise);
}
);
