/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

define(['jquery'], function ($) {
    function Palette(spec) {
        var parent = spec.parent;
        var item = spec.item;
        var exercise = spec.exercise;
        var paletteId = spec.paletteId;
        var paletteVariables = spec.variables;
        if (!paletteVariables)
            paletteVariables = ['x', 'y'];

        this.exercise = exercise;
        var Main = require('exercise/Main');

        if (Main.isTouchDevice()) {
            parent = $('#akit-palette');
            if (parent.length === 0) {
                parent = $('<div #akit-palette class="formulaeditorpalette touch-device"/>');
                $('body').append(parent);
                $('body').append('<div style="height:160px"/>'); //create space for palette at bottom of page
            }
        }

        var paletteSpec = {
            rekenen: [
                [//row 1
                    {symbol: '<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt", class: 'palette-button-operator palette-button-sqrt'},
                    {symbol: '<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd: "\\nthroot"},
                    {symbol: '<math><mi>π</mi></math>', cmd: "\\pi"}
                ]
            ],
            vergelijkingen: [
                [//row 1
                    {symbol: '<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt", class: 'palette-button-operator palette-button-sqrt'},
                    {symbol: '<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd: "\\nthroot"},
                    {symbol: '&#8744;', cmd: "\\lor"},
                    {symbol: '&#8743;', cmd: "\\wedge"},
                    {symbol: '<math><mi>π</mi></math>', cmd: "\\pi"},
                    {symbol: 'F', cmd: "\\bot"}
                ]
            ],
            bovenbouw: [
                [//row 1
                    {symbol: '<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt"},
                    {symbol: '<math><mroot><mi>a</mi><mi>b</mi></mroot></math>', cmd: "\\nthroot"},
                    {symbol: '&#8744;', cmd: "\\vee"},
                    {symbol: '&#8743;', cmd: "\\wedge"},
                    {symbol: '<math><mi>π</mi></math>', cmd: "\\pi"},
                    {symbol: 'F', cmd: "\\bot"},
                    {symbol: 'log', cmd: "\\logBase"},
                    {symbol: '`int_a^b`', cmd: "\\int", class: "palette-button-function palette-button-integral"},
                    {symbol: '`d/dx`', insert: "d/dx", class: "palette-button-function palette-button-integral"}
                ]
            ]

        };
        var paletteSpecTouch = {
            rekenen: [
                [//row 1
                    {symbol: '1', insert: '1'},
                    {symbol: '2', insert: '2'},
                    {symbol: '3', insert: '3'},
                    {symbol: '4', insert: '4'},
                    {symbol: '5', insert: '5'},
                    {symbol: '6', insert: '6'},
                    {symbol: '7', insert: '7'},
                    {symbol: '8', insert: '8'},
                    {symbol: '9', insert: '9'},
                    {symbol: '0', insert: '0'},
                    {symbol: ',', insert: ','},
                    {symbol: '&nbsp;', keydown: 8, class: "palette-button-backspace"}
                ],
                [//row 2
                    {symbol: paletteVariables[0], insert: paletteVariables[0], class: "palette-button-variable"},
                    {symbol: '↑', keydown: 38, class: "palette-button-func"}, //cursor up
                    {symbol: paletteVariables[1], insert: paletteVariables[1], class: "palette-button-variable"},
                    {symbol: '+', insert: '+', class: 'palette-button-operator'},
                    {symbol: '-', insert: '-', class: 'palette-button-operator'},
                    {symbol: '=', insert: '=', class: 'palette-button-operator'},
                    {symbol: '<', insert: '<', class: 'palette-button-operator'},
                    {symbol: '>', insert: '>', class: 'palette-button-operator'},
                    {symbol: '&le;', insert: '<=', class: 'palette-button-operator'},
                    {symbol: '&ge;', insert: '>=', class: 'palette-button-operator'},
                    {symbol: '&#8744;', cmd: '\\vee', class: 'palette-button-operator'},
                    {symbol: '`pi`', cmd: '\\pi'},
                ],
                [
                    {symbol: '←', keydown: 37, class: "palette-button-func"}, //cursor left
                    {symbol: '↓', keydown: 40, class: "palette-button-func"}, //cursor down
                    {symbol: '→', keydown: 39, class: "palette-button-func"}, //cursor right
                    {symbol: '`xx`', insert: '*', class: 'palette-button-operator'},
                    {symbol: '`-:`', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt", class: 'palette-button-operator palette-button-sqrt'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '(', insert: '('},
                    {symbol: ')', insert: ')'},
                    {symbol: 'hint', class: 'akit-hint-button', event: 'show-hint'},
                    {symbol: 'klaar', insert: '\n', class: "palette-button-enter"}

                ]
            ],
            vergelijkingen: [
                [//row 1
                    {symbol: '1', insert: '1'},
                    {symbol: '2', insert: '2'},
                    {symbol: '3', insert: '3'},
                    {symbol: '4', insert: '4'},
                    {symbol: '5', insert: '5'},
                    {symbol: '6', insert: '6'},
                    {symbol: '7', insert: '7'},
                    {symbol: '8', insert: '8'},
                    {symbol: '9', insert: '9'},
                    {symbol: '0', insert: '0'},
                    {symbol: ',', insert: ','},
                    {symbol: '&nbsp;', keydown: 8, class: "palette-button-backspace"}
                ],
                [//row 2
                    {symbol: paletteVariables[0], insert: paletteVariables[0], class: "palette-button-variable"},
                    {symbol: '↑', keydown: 38, class: "palette-button-func"}, //cursor up
                    {symbol: paletteVariables[1], insert: paletteVariables[1], class: "palette-button-variable"},
                    {symbol: '+', insert: '+', class: 'palette-button-operator'},
                    {symbol: '-', insert: '-', class: 'palette-button-operator'},
                    {symbol: '=', insert: '=', class: 'palette-button-operator'},
                    {symbol: '<', insert: '<', class: 'palette-button-operator'},
                    {symbol: '>', insert: '>', class: 'palette-button-operator'},
                    {symbol: '&le;', insert: '<=', class: 'palette-button-operator'},
                    {symbol: '&ge;', insert: '>=', class: 'palette-button-operator'},
                    {symbol: '&#8744;', cmd: '\\vee', class: 'palette-button-operator'},
                    {symbol: '`pi`', cmd: '\\pi'},
                ],
                [
                    {symbol: '←', keydown: 37, class: "palette-button-func"}, //cursor left
                    {symbol: '↓', keydown: 40, class: "palette-button-func"}, //cursor down
                    {symbol: '→', keydown: 39, class: "palette-button-func"}, //cursor right
                    {symbol: '`xx`', insert: '*', class: 'palette-button-operator'},
                    {symbol: '`-:`', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt", class: 'palette-button-operator palette-button-sqrt'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '(', insert: '('},
                    {symbol: ')', insert: ')'},
                    {symbol: 'hint', class: 'akit-hint-button', event: 'show-hint'},
                    {symbol: 'klaar', insert: '\n', class: "palette-button-enter"}

                ]
            ],
            bovenbouw: [
                [//row 1
                    {symbol: '1', insert: '1'},
                    {symbol: '2', insert: '2'},
                    {symbol: '3', insert: '3'},
                    {symbol: '4', insert: '4'},
                    {symbol: '5', insert: '5'},
                    {symbol: '6', insert: '6'},
                    {symbol: '7', insert: '7'},
                    {symbol: '8', insert: '8'},
                    {symbol: '9', insert: '9'},
                    {symbol: '0', insert: '0'},
                    {symbol: ',', insert: ','},
                    {symbol: '&nbsp;', keydown: 8, class: "palette-button-backspace"}
                ],
                [//row 2
                    {symbol: paletteVariables[0], insert: paletteVariables[0], class: "palette-button-variable"},
                    {symbol: '↑', keydown: 38, class: "palette-button-func"}, //cursor up
                    {symbol: paletteVariables[1], insert: paletteVariables[1], class: "palette-button-variable"},
                    {symbol: '+', insert: '+', class: 'palette-button-operator'},
                    {symbol: '-', insert: '-', class: 'palette-button-operator'},
                    {symbol: '=', insert: '=', class: 'palette-button-operator'},
                    {symbol: '<', insert: '<', class: 'palette-button-operator'},
                    {symbol: '>', insert: '>', class: 'palette-button-operator'},
                    {symbol: '&le;', insert: '<=', class: 'palette-button-operator'},
                    {symbol: '&ge;', insert: '>=', class: 'palette-button-operator'},
                    {symbol: '&#8744;', cmd: '\\vee', class: 'palette-button-operator'},
                    {symbol: '`pi`', cmd: '\\pi'},
                ],
                [
                    {symbol: '←', keydown: 37, class: "palette-button-func"}, //cursor left
                    {symbol: '↓', keydown: 40, class: "palette-button-func"}, //cursor down
                    {symbol: '→', keydown: 39, class: "palette-button-func"}, //cursor right
                    {symbol: '`xx`', insert: '*', class: 'palette-button-operator'},
                    {symbol: '`-:`', insert: '/', class: 'palette-button-operator'},
                    {symbol: '<math><msqrt><mtext></mtext></msqrt></math>', cmd: "\\sqrt", class: 'palette-button-operator palette-button-sqrt'},
                    {symbol: '<math><msup><mi>a</mi><mi>b</mi></msup></math>', insert: '^'},
                    {symbol: '(', insert: '('},
                    {symbol: ')', insert: ')'},
                    {symbol: 'hint', class: 'akit-hint-button', event: 'show-hint'},
                    {symbol: 'klaar', insert: '\n', class: "palette-button-enter"}

                ],
                [//row 4
                    {symbol: 'sin', cmd: "\\sin", class: "palette-button-function"},
                    {symbol: 'cos', cmd: "\\cos", class: "palette-button-function"},
                    {symbol: 'tan', cmd: "\\tan", class: "palette-button-function"},
                    {symbol: 'log', cmd: "\\logBase", class: "palette-button-function"},
                    {symbol: 'ln', cmd: "\\ln", class: "palette-button-function"},
                    {symbol: '`int_a^b`', cmd: "\\int", class: "palette-button-function palette-button-integral"},
                    {symbol: '`d/dx`', cmd: "\\int", class: "palette-button-function palette-button-integral"}
                ]
            ]
        };
        var funckeySpec = {
            none: [
                []
            ],
            default: [
                [//row 1
                    {symbol: '?', class: 'akit-hint-button', event: 'show-hint'}
                ]
            ]
        };

        function keypressed(s) {
            var item = exercise.activeItem;
            item.focus();
            if (s.insert) {
                item.editor.typedText(s.insert);
            } else if (s.cmd) {
                item.editor.cmd(s.cmd);
            } else if (s.keydown) {
                var cmd;
                switch (s.keydown) {
                    case 8:
                        cmd = 'Backspace';
                        break;
                    case 37:
                        cmd = 'Left';
                        break;
                    case 39:
                        cmd = 'Right';
                        break;
                    case 38:
                        cmd = 'Up';
                        break;
                    case 40:
                        cmd = 'Down';
                        break;
                    default:
                        alert('unkown key: ' + s.keydown);
                }
                item.editor.keystroke(cmd);
            } else if (s.event) {
                switch (s.event) {
                    case 'show-hint':
                        exercise.getHint();
                        break;
                }

            }
        }
        function addbuttons(spec, container) {
            for (var row = 0; row < spec.length; row++) {
                var rowSpec = spec[row];
                var rowelm = $('<div class="palette-row"></div>');
                container.append(rowelm);
                rowelm.nodoubletapzoom();
                for (var col = 0; col < rowSpec.length; col++) {
                    var elm = $('<div class="palette-button"></div>');
                    var s = rowSpec[col];
                    if (s.class)
                        elm.addClass(s.class);
                    rowelm.append(elm);
                    elm.nodoubletapzoom();
                    var textElm = elm;//$('.palette-button-inner', elm);
                    textElm.html(s.symbol);
                    (function (s) {
                        textElm.click(
                                function (e) {
                                    keypressed(s);
                                    e.stopPropagation();
                                }
                        );
                    }(rowSpec[col]));
                }
                rowelm.append('<div style="clear:both"></div>');
            }
        }

        return {
            parent: $(parent),
            draw: function (paletteId, funcPaletteId) {
                var pkeypad = $('<div class="palette-keypad"></div>');
                var funckeys = $('<div class="palette-funckeys"></div>');

                if (Main.isTouchDevice()) {
                    parent.append(pkeypad);
//                    pkeypad.append(funckeys);
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

                if (!spec)
                    alert('Unknown palette: ' + paletteId);
                addbuttons(spec, pkeypad);
                addbuttons(funckeySpec[funcPaletteId], funckeys);
                MathJax.Hub.Queue(["Typeset", MathJax.Hub]);

            },
            show: function () {
                this.parent.addClass('visible');
            },
            hide: function () {
                this.parent.removeClass('visible');
            },
            remove: function () {
                this.parent.remove();
            }
        };
    }
    return (Palette);
});

