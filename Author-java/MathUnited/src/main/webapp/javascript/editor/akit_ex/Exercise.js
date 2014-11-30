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

define(["require", "akitex/Engine", "akitex/ExerciseItem"], function(require, Engine, ExerciseItem) {
    //spec:
    // - id 
    // - dom : $('.akit-exercise')
    // - onFinished : callback 
    function Exercise(spec) {
        var id = spec.id;
        var dom = $(spec.dom);
        var orgDom = dom.html(); //store original state for revert()
        dom.attr('id', 'akit-exercise-' + id);
        var paletteId = dom.attr('palette');
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
                if(this.dom.hasClass('akit-init-open')) {create();} 
                else  dom.click(function() { create(); });

                //execute general scripts (not nested in an akit-item)
                dom.children('.akit-script').each(function() {
                    _this.executeScript($(this));
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
                        doAnimate: spec.doAnimate,
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
                this.variables[v.name]={mathml:v.mathml, definition:v.definition};
            }
        };
        return obj;
    }
    return (Exercise);
}
);
