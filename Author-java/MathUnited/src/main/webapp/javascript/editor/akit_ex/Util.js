/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery'], function($) {
    var TAGNAMES = {
      'select':'input','change':'input',
      'submit':'form','reset':'form',
      'error':'img','load':'img','abort':'img'
    }
    
    return {

        //required when copying html containing MathJax 
        normalizeMathJax : function(elm) {
            $('.MathJax_Preview', elm).remove();
            $('.MathJax', elm).remove();

            $('script', elm).each(function() {
                var str = $(this).text();
                if ($(this).attr('type') === 'math/asciimath') {
                    $(this).replaceWith($('<span>`' + str + '`</span>'));
                } else {
                    $(this).replaceWith($('<span>' + str + '</span>'));
                }
            });
        },
        
        //from: http://perfectionkills.com/detecting-event-support-without-browser-sniffing/
        isEventSupported : function(eventName) {
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



