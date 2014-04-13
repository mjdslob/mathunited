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

define(['algebrakit/Engine', 'algebrakit/StepPanel', 'jquery','jqueryui','jqueryChosen'], function(engine, StepPanel, $) {
    $('head').append('<link rel="stylesheet" href="css/StepPanel.css" type="text/css" />');
    var dialog_html = 
            '<div class="akit-container">'
           +'  <p>Diff[ sin[x^2] ]</p> <p> LosOp[5g+1=2g+13]</p>'
           +'  <select class="audience-choser" data-placeholder="selecteer de doelgroep...">'
           +'     <option value="rekenen">rekenen</option>'
           +'     <option value="onderbouw">onderbouw</option>'
           +'     <option value="vwo-b">bovenbouw</option>'
           +'  </select>'
           +'  <div class="akit-input-wrapper">'
           +'     Invoer: <input type="text" width=80></input>'
           +'  </div>'
           +'  <div class="akit-derivation"></div>'
           +'  <div class="akit-button-container"><div class="akit-button akit-cancel">annuleren</div><div class="akit-button akit-ok">OK</div></div>'
           +'</div>'

    return {
        show: function(parent, callback_ok) {
            var dialog = $(dialog_html).dialog({width:300, height:400, dialogClass: "akit"});
            var panel = null;
            $('.audience-choser', dialog).chosen({width:200});
            $('.akit-ok',dialog).click(function() {
                if(panel) {
                    debugger;
                    var str = panel.getEditorRendering();
                    parent.append($(str));
                    dialog.dialog('close');
                }
            });
            $('.akit-cancel',dialog).click(function() {
                    dialog.dialog('close');
            });
            $('.akit-input-wrapper input').change(function() {
               var exp=$(this).val(); 
               engine.solve(exp, 'uitlegfolio', function(data) {
                   var solution = $.parseXML(data.result);
                   
                   solution.normalize();
                   var mainstep = $('step', solution).first();
                   //mainstep.children('steplist').children('step').first().remove();
                   var step = StepPanel.AKIT_ParseStepXML( mainstep );
                   $('.akit-derivation', dialog).empty();
                   panel = new StepPanel.StepPanel(step, $('.akit-derivation', dialog) );
                   panel.showExplanation();
               });
            });
        }  
    };
});