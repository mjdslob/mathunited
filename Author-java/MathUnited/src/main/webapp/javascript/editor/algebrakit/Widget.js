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
    var cssAppended = false;
    var dialog_html = 
            '<div class="akit-container">'
//           +'  <p>Diff[ sin[x^2] ]</p> <p> LosOp[5g+1=2g+13]</p> <p>LosOp[4t^2+50=200]</p> <p>LosOp[(x+1)(x+4)=30]</p>'
           +'  <select class="command-chooser" data-placeholder="opdracht...">'
           +'     <option value=""></option>'
           +'     <option value="LosOp[%]">oplossen</option>'
           +'     <option value="Diff[%]">differenti&euml;ren</option>'
           +'     <option value="Expand[%]">haakjes wegwerken</option>'
           +'     <option value="Factor[%]">ontbinden</option>'
           +'     <option value="Integreer[%]">primitiveren</option>'
           +'  </select>'
           +'  <div class="akit-input-wrapper">'
           +'     Invoer: <input type="text" style="width:300px;"></input>'
           +'  </div>'
           +'  <div class="akit-derivation"></div>'
           +'  <div class="akit-button-container"><div class="akit-button akit-cancel">annuleren</div><div class="akit-button akit-ok">OK</div></div>'
           +'</div>';
   
    function Widget() {
        if(!cssAppended) {
            $('head').append('<link rel="stylesheet" href="css/StepPanel.css" type="text/css" />');
            cssAppended = true;
        }

        return {
            dialog : null,
            panel : null,
            show: function(parent, callback_ok) {
                var _this = this;
                this.dialog = $(dialog_html).dialog({width:500, height:600, dialogClass: "akit"});
                $('.command-chooser', this.dialog).chosen({width:200});
                $('.akit-ok',this.dialog).click(function() {
                    if(_this.panel) {
                        var str = _this.panel.getEditorRendering();
                        parent.append($(str));
                        _this.dialog.dialog('close');
                    }
                });
                $('.akit-cancel',this.dialog).click(function() {
                        _this.dialog.dialog('close');
                });
                $('select.command-chooser',this.dialog).change(function() {
                    var asm = $(this).val();
                    var exp = $('.akit-input-wrapper input',_this.dialog).val();
                    if(asm) exp = asm.replace('%',exp);
                    if(exp) _this.execute(exp);
                });
                $('.akit-input-wrapper input',this.dialog).keypress(function(e) {
                    if(e.which === 13) {
                        var asm = $('select.command-chooser',_this.dialog).val();
                        var exp=$(this).val(); 
                        if(asm) exp = asm.replace('%',exp);
                        _this.execute(exp);
                    }
                });
            },
            execute: function(exp) {
                var _this = this;
                engine.solve(exp, 'uitlegfolio', function(data) {
                    var solution = $.parseXML(data.result);

                    solution.normalize();
                    var mainstep = $('step', solution).first();
                    //mainstep.children('steplist').children('step').first().remove();
                    var step = StepPanel.AKIT_ParseStepXML( mainstep );
                    $('.akit-derivation', _this.dialog).empty();
                    _this.panel = new StepPanel.StepPanel(step, $('.akit-derivation', _this.dialog) );
                    _this.panel.showExplanation();
                });

            }
        };
    }
    return (Widget);


});