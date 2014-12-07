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
define(['jquery'], function($) {    
    function Palette(parent, item, exercise) {
        this.exercise = exercise;
        
        var isTouchDevice = ("ontouchstart" in document.documentElement);
        //isTouchDevice=true;
        if(isTouchDevice) {
            parent = $('#akit-palette');
            if(parent.length===0) {
                parent = $('<div #akit-palette class="formulaeditorpalette touch-device"/>');
                $('body').append(parent);
                $('body').append('<div style="height:160px"/>'); //create space for palette at bottom of page
            }
        }
        
        var paletteSpec = {
            rekenen: [
                  [//row 1
                    {symbol:'<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\nthroot"},
                    {symbol:'<math><mi>π</mi></math>', cmd:"\\pi"}
                  ]
                ],
            vergelijkingen: [
                  [//row 1
                    {symbol:'<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\nthroot"},
                    {symbol:'&#8744;', cmd:"\\lor"},
                    {symbol:'&#8743;', cmd:"\\wedge"},
                    {symbol:'<math><mi>π</mi></math>', cmd:"\\pi"}
                  ]
                ],
            bovenbouw: [
                  [//row 1
                    {symbol:'<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\nthroot"},
                    {symbol:'log', cmd:"\\logBase"},
                    {symbol:'&#8744;', cmd:"\\vee"},
                    {symbol:'&#8743;', cmd:"\\wedge"},
                    {symbol:'<math><mi>π</mi></math>', cmd:"\\pi"}
                  ]
                ],
            metGonio: [
                  [//row 1
                    {symbol:'7', insert:'7'},
                    {symbol:'8', insert:'8'},
                    {symbol:'9', insert:'9'},
                    {symbol:'+', insert:'+', class:'palette-button-operator'},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'↵', charCode: 13, class:"palette-button-enter"},
                    {symbol:'x', insert:'x', class:"palette-button-variable"},
                    {symbol:'cos', cmd:"\\cos", class:"palette-button-variable"},
                    {symbol:'(', insert:'('},
                    {symbol:'<math><mi>π</mi></math>', cmd:"\\pi"}
                  ],
                  [//row 2
                    {symbol:'4', insert:'4'},
                    {symbol:'5', insert:'5'},
                    {symbol:'6', insert:'6'},
                    {symbol:':', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'&nbsp;', keydown:8, class:"palette-button-backspace"},
                    {symbol:'y', insert:'y', class:"palette-button-variable"},
                    {symbol:'sin', cmd:"\\sin"},
                    {symbol:')', insert:')'},
                  ],
                  [//row 3
                    {symbol:'1', insert:'1'},
                    {symbol:'2', insert:'2'},
                    {symbol:'3', insert:'3'},
                    {symbol:'-', insert:'-', class:'palette-button-operator'},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\sqrt[n]"},
                    {symbol:'↑', keydown:38}, //cursor up
                    {symbol:'t', insert:'t', class:"palette-button-variable"},
                    {symbol:'tan', cmd:"\\tan", class:"palette-button-variable"}
                  ],
                  [//row 4
                    {symbol:'.', insert:'.'},
                    {symbol:'0', insert:'0'},
                    {symbol:'=', insert:'=', class:'palette-button-operator'},
                    {symbol:'&#xD7;', insert:'*', class:'palette-button-operator'},
                    {symbol:'←', keydown:37}, //cursor left
                    {symbol:'↓', keydown:40}, //cursor down
                    {symbol:'→', keydown:39}, //cursor right
                    {symbol:"<math><mfenced><mi></mi></mfenced><mo>'</mo></math>", insert:"'", class:"palette-button-variable"}
                    
                  ]
                ]
                
        };
        var paletteSpecTouch = {
            rekenen: [
                  [//row 1
                    {symbol:'1', insert:'1'},
                    {symbol:'2', insert:'2'},
                    {symbol:'3', insert:'3'},
                    {symbol:'4', insert:'4'},
                    {symbol:'5', insert:'5'},
                    {symbol:'6', insert:'6'},
                    {symbol:'7', insert:'7'},
                    {symbol:'8', insert:'8'},
                    {symbol:'9', insert:'9'},
                    {symbol:'0', insert:'0'},
                    {symbol:'&nbsp;', keydown:8, class:"palette-button-backspace"}
                  ],
                  [//row 2
                    {symbol:'&nbsp;', insert:' '}, //cursor up
                    {symbol:'↑', keydown:38}, //cursor up
                    {symbol:'x', insert:'x', class:"palette-button-variable"},
                    {symbol:'+', insert:'+', class:'palette-button-operator'},
                    {symbol:'-', insert:'-', class:'palette-button-operator'},
                    {symbol:'=', insert:'=', class:'palette-button-operator'},
                    {symbol:'<', insert:'<', class:'palette-button-operator'},
                    {symbol:'>', insert:'>', class:'palette-button-operator'},
                    {symbol:'&le;', insert:'<=', class:'palette-button-operator'},
                    {symbol:'&ge;', insert:'>=', class:'palette-button-operator'},
                    {symbol:'&#8744;', cmd:'\\vee', class:'palette-button-operator'},

                  ],
                  [
                    {symbol:'←', keydown:37}, //cursor left
                    {symbol:'↓', keydown:40}, //cursor down
                    {symbol:'→', keydown:39}, //cursor right
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'/', insert:'/', class:'palette-button-operator'},
                    {symbol:'(', insert:'('},
                    {symbol:')', insert:')'},
                    {symbol:',', insert:','}, //cursor up
                    {symbol:'↵', charCode: 13, class:"palette-button-enter"}
                  ]
                ],
            vergelijkingen: [
                  [//row 1
                    {symbol:'7', insert:'7'},
                    {symbol:'8', insert:'8'},
                    {symbol:'9', insert:'9'},
                    {symbol:'+', insert:'+', class:'palette-button-operator'},
                    {symbol:'(', insert:'('},
                    {symbol:')', insert:')'},
                    {symbol:'&#8743;', cmd:"\\wedge"},
                    {symbol:'↵', charCode: 13, class:"palette-button-enter"}
                  ],
                  [//row 2
                    {symbol:'4', insert:'4'},
                    {symbol:'5', insert:'5'},
                    {symbol:'6', insert:'6'},
                    {symbol:':', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\nthroot"},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'x', insert:'x', class:"palette-button-variable"}
                  ],
                  [//row 3
                    {symbol:'1', insert:'1'},
                    {symbol:'2', insert:'2'},
                    {symbol:'3', insert:'3'},
                    {symbol:'-', insert:'-', class:'palette-button-operator'},
                    {symbol:"'", insert:"'"}, //cursor up
                    {symbol:'↑', keydown:38}, //cursor up
                    {symbol:'&#8744;', cmd:"\\vee"},
                    {symbol:'a', insert:'a', class:"palette-button-variable"}
                  ],
                  [//row 4
                    {symbol:',', insert:','},
                    {symbol:'0', insert:'0'},
                    {symbol:'=', insert:'=', class:'palette-button-operator'},
                    {symbol:'&#xD7;', insert:'*', class:'palette-button-operator'},
                    {symbol:'←', keydown:37}, //cursor left
                    {symbol:'↓', keydown:40}, //cursor down
                    {symbol:'→', keydown:39}, //cursor right
                    {symbol:'t', insert:'t', class:"palette-button-variable"}
                    
                  ]
                ],
            metGonio: [
                  [//row 1
                    {symbol:'7', insert:'7'},
                    {symbol:'8', insert:'8'},
                    {symbol:'9', insert:'9'},
                    {symbol:'+', insert:'+', class:'palette-button-operator'},
                    {symbol:'<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert:'^'},
                    {symbol:'↵', charCode: 13, class:"palette-button-enter"},
                    {symbol:'x', insert:'x', class:"palette-button-variable"},
                    {symbol:'cos', cmd:"\\cos", class:"palette-button-variable"},
                    {symbol:'(', insert:'('}
                  ],
                  [//row 2
                    {symbol:'4', insert:'4'},
                    {symbol:'5', insert:'5'},
                    {symbol:'6', insert:'6'},
                    {symbol:':', insert:'/', class:'palette-button-operator'},
                    {symbol:'<math><msqrt><mtext></mtext></msqrt></math>', cmd:"\\sqrt"},
                    {symbol:'<math><mi>π</mi></math>', insert:"<OMS cd='nums1' name='pi'/>"},
                    {symbol:'y', insert:'y', class:"palette-button-variable"},
                    {symbol:'sin', cmd:"\\sin", class:"palette-button-variable"},
                    {symbol:')', insert:')'},
                  ],
                  [//row 3
                    {symbol:'1', insert:'1'},
                    {symbol:'2', insert:'2'},
                    {symbol:'3', insert:'3'},
                    {symbol:'-', insert:'-', class:'palette-button-operator'},
                    {symbol:'<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd:"\\nthroot"},
                    {symbol:'↑', keydown:38}, //cursor up
                    {symbol:'t', insert:'t', class:"palette-button-variable"},
                    {symbol:'tan', cmd:"\tan", class:"palette-button-variable"}
                  ],
                  [//row 4
                    {symbol:'.', insert:'.'},
                    {symbol:'0', insert:'0'},
                    {symbol:'=', insert:'=', class:'palette-button-operator'},
                    {symbol:'&#xD7;', insert:'*', class:'palette-button-operator'},
                    {symbol:'←', keydown:37}, //cursor left
                    {symbol:'↓', keydown:40}, //cursor down
                    {symbol:'→', keydown:39}, //cursor right
                    {symbol:"<math><mfenced><mi></mi></mfenced><mo>'</mo></math>", insert:"'", class:"palette-button-variable"}
                    
                  ]
                ]
        };
        var funckeySpec = {
            none: [
                []
            ],
            default: [
                    [//row 1
                        {symbol:'?', class:'akit-hint-button', event:'show-hint'}
                    ]
            ]
        };

        function keypressed(s) {
           var item = exercise.activeItem;
           item.focus();
           if(s.insert){
               item.editor.typedText(s.insert);
           } else if(s.cmd) {
               item.editor.cmd(s.cmd);
           } else if(s.charCode) {
                 var event = {
                     type: 'keypress',
                     which: '',
                     charCode: s.charCode,
                     keyCode: s.charCode
                 };
                 item.editor.onkeypress(event);
            } else if(s.keydown) {
                 var event = {
                     type: 'keydown',
                     which: '',
                     charCode: s.keydown,
                     keyCode: s.keydown
                 };
                 item.editor.onkeydown(event);
            } else if(s.event) {
                switch(s.event) {
                    case 'show-hint':
                        exercise.getHint();
                        break;
                }
                
            }
        }
        function addbuttons(spec, container) {
            for(var row=0; row<spec.length;row++) {
                var rowSpec = spec[row];
                var rowelm = $('<div class="palette-row"></div>');
                container.append(rowelm);
                rowelm.nodoubletapzoom();
                for(var col=0; col<rowSpec.length; col++) {
                    var elm = $('<div class="palette-button"></div>');
                    var s = rowSpec[col];
                    if(s.class) elm.addClass(s.class);
                    rowelm.append(elm);
                    elm.nodoubletapzoom();
                    var textElm = elm;//$('.palette-button-inner', elm);
                    textElm.html(s.symbol);
                    (function(s) {
                        textElm.click(
                           function(e) {
                               keypressed(s);
                               e.stopPropagation();
                           }
                        );
                    }(rowSpec[col]) );
                }
                rowelm.append('<div style="clear:both"></div>');
            }
        }

        return {
            parent: $(parent),
            draw: function(paletteId, funcPaletteId) {
                var pkeypad = $('<div class="palette-keypad"></div>');
                var funckeys = $('<div class="palette-funckeys"></div>');

                if(isTouchDevice) {
                    parent.append(funckeys);
                    parent.append(pkeypad);
                    var spec = paletteSpecTouch[paletteId];
                } else {
                    parent.append(pkeypad);
                    parent.append(funckeys);
                   var spec = paletteSpec[paletteId];
                }

                parent.append($('<div style="clear:both"></div>'));
                parent.nodoubletapzoom();
                pkeypad.nodoubletapzoom();
                funckeys.nodoubletapzoom();

                if(!spec) alert('Unknown palette: '+paletteId);
                addbuttons(spec,pkeypad);
                addbuttons(funckeySpec[funcPaletteId],funckeys);
                MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
                
            },
            show: function() {this.parent.addClass('visible');},
            hide: function() {this.parent.removeClass('visible');},
            remove: function() {this.parent.remove();}
        };
    }
    return (Palette);
});

