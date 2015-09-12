/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery', 'akit/Parser'], function ($, AKITParser) {
    var TAGNAMES = {
        'select': 'input', 'change': 'input',
        'submit': 'form', 'reset': 'form',
        'error': 'img', 'load': 'img', 'abort': 'img'
    }

    return {
        //replace the contents of parent with the HTMLstring. Mathematical expressions
        //are also rendered.
        toDOM: function(HTMLstring, elm_jq) {
            var xmlStr = this.replaceEntities(HTMLstring);
            var xml = $.parseXML(xmlStr);
            AKITParser.parse(xml, elm_jq[0]);
        },
        replaceEntities: function(str) {
           str = str.replace(/&or;/g, '&#x2228;');
           str = str.replace(/&eacute;/g, '&#x00E9;');
           str = str.replace(/&euml;/g, '&#x00EB;');
           str = str.replace(/&iuml;/g, '&#239;');
           str = str.replace(/&sdot;/g, '&#x22C5;');
           str = str.replace(/&prime;/g, '&#8242;');
           str = str.replace(/&pi;/g, '&#x03C0;');
           str = str.replace(/&and;/g, '&#x2227;');
           str = str.replace(/&or;/g, '&#x2228;');
           str = str.replace(/&ne;/g, '&#x2260;');
           str = str.replace(/&le;/g, '&#x2264;');
           str = str.replace(/&ge;/g, '&#x2265;');
           return str;
        },
        //required when copying html containing MathJax 
        normalizeMathJax: function (elm) {
            $('.MathJax_Preview', elm).remove();
            $('.MathJax', elm).remove();

            $('script', elm).each(function () {
                var str = $(this).text();
                if ($(this).attr('type') === 'math/asciimath') {
                    $(this).replaceWith($('<span>`' + str + '`</span>'));
                } else {
                    $(this).replaceWith($('<span>' + str + '</span>'));
                }
            });
        },
        //from: http://perfectionkills.com/detecting-event-support-without-browser-sniffing/
        isEventSupported: function (eventName) {
            var el = document.createElement(TAGNAMES[eventName] || 'div');
            eventName = 'on' + eventName;
            var isSupported = (eventName in el);
            if (!isSupported) {
                el.setAttribute(eventName, 'return;');
                isSupported = typeof el[eventName] == 'function';
            }
            el = null;
            return isSupported;
        }
    };
}
);



