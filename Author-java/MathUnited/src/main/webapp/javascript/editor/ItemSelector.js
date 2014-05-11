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

define(['jquery', 'jqueryui', 'jqueryChosen'], function($) {
    var getComponentItemsURL = '/MathUnited/getcomponentitems';
    var isInitialized = false;
    var modules = [];
    var methods = [];
    var roots = [];
    var threads = [];

    function loadMethodData(url, callback) {
        $.get(url,
                function(xml) {
                    var sel = $(xml).find('method');

                    sel.each(function() {
                        var method = {
                            name: $(this).attr('id'),
                            title: $(this).children('title').text(),
                            components: []
                        };
                        methods.push(method);

                        $(this).find('component').each(function() {
                            var comp_id = $(this).attr('id');
                            var comp_name = $(this).children('title').text();
                            var comp_file = $(this).attr('file');
                            var elm_state = $(this).children('state');
                            if (elm_state) {
                                var comp_state = elm_state.attr('type');
                            }
                            if (!comp_state)
                                comp_state = 'underconstruction';
                            var sc = $(this).find('subcomponents');
                            var subcomponents = [];
                            if (sc) {
                                sc.find('subcomponent').each(function() {
                                    var sub_name = $(this).children('title').text();
                                    var sub_file = $(this).children('file').text();
                                    var sub_id = $(this).attr('id');

                                    var subcomponent = {
                                        title: sub_name,
                                        file: sub_file,
                                        id: sub_id
                                    };
                                    subcomponents.push(subcomponent);
                                });
                            }

                            var module = {
                                id: comp_id,
                                name: comp_name,
                                file: comp_file,
                                publishState: comp_state,
                                method: method,
                                subcomponents: subcomponents
                            };
                            modules[comp_id] = module; //store with id as key
                            modules.push(module);    //also store as array (for loops)

                        }); //close each on component
                    }); //close each on method
                    callback();
                }
        );
    }

    function loadThreads(url, callback) {
        $.get(url,
                function(xml) {
                    var sel;
                    sel = $(xml).find('thread');
                    if (!sel || sel.length === 0) {
                        //alert('Geen leerlijnen gevonden.');
                    }
                    sel.each(function() {
                        var threadId = $(this).attr('id');
                        var thread = {
                            id: threadId,
                            info: $(this).children('information').text(),
                            title: $(this).children('title').text(),
                            type: $(this).children('schooltype').text(),
                            year: $(this).children('year').text(),
                            modules: []
                        };
                        var p = $(this).children('threadsequence');
                        p.children('contentref').each(function() {
                            var ref = $(this).attr('ref');
                            var met = $(this).attr('method');
                            var mod = modules[ref];
                            if (mod)
                                thread.modules.push(mod);
                        }) //close each on contentref
                        threads.push(thread);
                        threads[threadId] = thread;
                    });

                    //retain only the modules from the threads
                    for (var ii = 0; ii < threads.length; ii++) {
                        var thr = threads[ii];
                        for (var jj = 0; jj < thr.modules.length; jj++) {
                            var mod = thr.modules[jj];
                            if (!modules[ mod.id ]) {
                                modules[ mod.id ] = mod;
                                modules.push(mod);
                            }
                        }
                    }
                    callback();
                }
        );
    }

    var itemNameMap = {
        introduction: 'inleiding',
        explore: 'verkennen',
        explanation: 'uitleg',
        example: 'voorbeeld',
        exercise: 'opgave',
        theory: 'theorie',
        digest: 'verwerken',
        extra: 'practicum',
        test: 'test jezelf'
    };

    function addItemOption(item, elm) {

        item.children().each(function() {
            addItemOption($(this), elm);
        });

        var id = item.attr('id');
        var nr = item.attr('_nr');
        if (!nr)
            nr = '';
        function writeItem(name) {
            //id is used through closure
            if (id)
                elm.append($('<option value="' + id + '">' + name + ' ' + nr + '</option>'));
            else
                elm.append($('<option value="unknown" disabled>' + name + ' ' + nr + '</option>'));
        }

        if (item.length > 0) {
            var name = itemNameMap[ item[0].localName ];
            if (name) {
                writeItem(name);
            }
        }
    }

    //find informative name for this item. Callback is only called if a name is found
    function getItemName(compid, subcompid, itemid, callback) {
        var args = {comp: compid, subcomp: subcompid};
        $.get(getComponentItemsURL, args,
                function(data) {
                    var sc = $('subcomponent#' + subcompid, data);
                    var item = $('#' + itemid, sc).first();
                    if (item.length > 0) {
                        var name = itemNameMap[ item[0].localName ];
                        if (name)
                            callback({id: itemid, name: name});
                    }
                });
    }

    function setItemOptions(comp, subcomp, div, callback) {
        clearItemOptions(div);
        var elm = $('.item-choser', div);
        var args = {comp: comp, subcomp: subcomp};
        $.get(getComponentItemsURL, args,
                function(data) {
                    var sc = $('subcomponent#' + subcomp, data);
                    addItemOption(sc, elm);
                    elm.trigger('chosen:updated');
                    if (callback)
                        callback();
                });

    }
    function clearItemOptions(div) {
        var elm = $('.item-choser', div);
        $('option', elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
    }
    function setSubcomponentOptions(compId, div) {
        clearSubcomponentOptions(div);
        var elm = $('.subcomponent-choser', div);
        var mod = modules[compId];
        for (var jj = 0; jj < mod.subcomponents.length; jj++) {
            var sub = mod.subcomponents[jj];
            elm.append('<option value="' + sub.id + '">' + sub.title + '</option>');
        }
        elm.trigger('chosen:updated');
    }
    function clearSubcomponentOptions(div) {
        var elm = $('.subcomponent-choser', div);
        $('option', elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
        clearItemOptions(div);
    }
    function setComponentOptions(threadId, div) {
        var elm = $('.component-choser', div);
        clearComponentOptions(div);
        var th = threads[threadId];
        for (var jj = 0; jj < th.modules.length; jj++) {
            var mod = th.modules[jj];
            elm.append('<option value="' + mod.id + '">' + mod.name + '</option>');
        }
        elm.trigger('chosen:updated');
    }
    function clearComponentOptions(div) {
        var elm = $('.component-choser', div);
        $('option', elm).remove();
        elm.append($('<option value=""></option>'));
        elm.trigger('chosen:updated');
        clearSubcomponentOptions(div);
    }

    function setThreadOptions(div) {
        var elm = $('.thread-choser', div);
        for (var ii = 0; ii < threads.length; ii++) {
            var th = threads[ii];
            if (th) {
                elm.append($('<option value="' + th.id + '">' + th.title + '</option>'));
            }
        }

    }

    var selectedThread = {id: null, name: null};
    var selectedComponent = {id: null, name: null};
    var selectedSubcomponent = {id: null, name: null};
    var selectedItem = {id: null, name: null};

    return {
        init: function(methodURL, threadURL) {
            loadMethodData(methodURL, function() {
                loadThreads(threadURL, function() {
                    isInitialized = true;
                });
            });
        },
        show: function(current, callback_ok) {
            if (!isInitialized) {
                alert('Probleem: kan de beschikbare paragrafen niet laden');
                return;
            }
            var parent = $('<div><select class="thread-choser" data-placeholder="selecteer een leerlijn..."><option value=""></option></select>'
                    + '<br/><select class="component-choser" data-placeholder="selecteer een hoofdstuk..."></select>'
                    + '<br/><select class="subcomponent-choser" data-placeholder="selecteer een paragraaf..."></select>'
                    + '<br/><select class="item-choser" data-placeholder="selecteer een item..."></select>'
                    + '<div class="choser-button-container"><div class="choser-button choser-cancel">annuleren</div><div class="choser-button choser-ok">OK</div></div>'
                    + '</div>');
            $('.contentDiv').prepend(parent);
            setThreadOptions(parent);

            if (current) {
                var _this = this;
                this.getSelectedElements(current, function(spec) {
                    if (current.threadid) {
                        $('.thread-choser option[value="' + current.threadid + '"]', parent).attr('selected', 'selected');
                        $('.thread-choser', parent).trigger('chosen:updated');
                        selectedThread.id = current.threadid;
                        selectedThread.name = spec.thread.name;
                        setComponentOptions(current.threadid, parent);
                    }
                    if (current.compid) {
                        $('.component-choser option[value="' + current.compid + '"]', parent).attr('selected', 'selected');
                        $('.component-choser', parent).trigger('chosen:updated');
                        selectedComponent.id = current.compid;
                        selectedComponent.name = spec.component.name;
                        setSubcomponentOptions(current.compid, parent);
                    }
                    if (current.subcompid) {
                        $('.subcomponent-choser option[value="' + current.subcompid + '"]', parent).attr('selected', 'selected');
                        $('.subcomponent-choser', parent).trigger('chosen:updated');
                        selectedSubcomponent.id = current.subcompid;
                        selectedSubcomponent.name = spec.subcomponent.name;
                        setItemOptions(selectedComponent.id, current.subcompid, parent, function() {
                            if (current.itemid) {
                                $('.item-choser option[value="' + current.itemid + '"]', parent).attr('selected', 'selected');
                                $('.item-choser', parent).trigger('chosen:updated');
                                selectedItem.id = current.itemid;
                                selectedItem.name = spec.item.name;
                            }
                        });
                    }
                });
            }



            parent.dialog({width: 300, height: 400});
            $('.thread-choser', parent).chosen()
                    .change(function(data) {
                        var id = $('.thread-choser option:selected', parent).val();
                        selectedThread.id = id;
                        selectedThread.name = $('.thread-choser option:selected', parent).text();
                        setComponentOptions(id, parent);
                    });
            $('.component-choser', parent).chosen()
                    .change(function(data) {
                        var id = $('.component-choser option:selected', parent).val();
                        selectedComponent.id = id;
                        selectedComponent.name = $('.component-choser option:selected', parent).text();
                        setSubcomponentOptions(id, parent);
                    });
            $('.subcomponent-choser', parent).chosen()
                    .change(function(data) {
                        var subid = $('.subcomponent-choser option:selected', parent).val();
                        selectedSubcomponent.id = subid;
                        selectedSubcomponent.name = $('.subcomponent-choser option:selected', parent).text();
                        setItemOptions(selectedComponent.id, subid, parent);
                    });
            $('.item-choser', parent).chosen().change(function(data) {
                selectedItem.id = $('.item-choser option:selected', parent).val();
                selectedItem.name = $('.item-choser option:selected', parent).text();
            });
            $('.choser-ok', parent).click(function() {
                var result = {thread: selectedThread, component: selectedComponent, subcomponent: selectedSubcomponent, item: selectedItem};
                callback_ok(result);
                parent.dialog('close');
            });
            $('.choser-cancel', parent).click(function() {
                parent.dialog('close');
            });
        },
        getSelectedElements: function(spec, callback) {
            var result = {};
            if (spec.threadid) {
                result.thread = {id: spec.threadid, name: threads[spec.threadid].title};
            }
            if (spec.compid) {
                var comp = modules[spec.compid];
                if (comp) {
                    result.component = {id: spec.compid, name: comp.name};
                }
                var ii;
                var sub = null;
                for (ii = 0; ii < comp.subcomponents.length; ii++) {
                    if (comp.subcomponents[ii].id === spec.subcompid) {
                        sub = comp.subcomponents[ii];
                        break;
                    }
                }
                if (sub) {
                    result.subcomponent = {id: sub.id, name: sub.title};
                    getItemName(spec.compid, spec.subcompid, spec.itemid, function(item) {
                        result.item = item;
                        callback(result);
                    });
                }
            }
        }

    };
});