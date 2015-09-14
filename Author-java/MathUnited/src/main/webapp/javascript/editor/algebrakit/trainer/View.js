define(['akit/StepPanel', 'jquery', 'mathjax', 'jqueryui'], function (StepPanel,$) {
   
    var WIDGET_HTML = 
         '<div class="akit-container">'
        +'   <div class="akit-logo"></div>'
        +'   <div class="akit-panel">'
        +'     <div class="akit-panel-text"></div>'
        +'     <div class="akit-button akit-button-repeat"></div>'
        +'     <div class="akit-button akit-button-solve"></div>'
        +'   </div>'
        +'   <div class="akit-output">'
        +'   </div>'
        +'</div>';

    var dom_jq;

    return {
        //dom: root node to contain the trainer frontend
        init: function(spec) {
            dom_jq = spec.dom;
            dom_jq.append($(WIDGET_HTML));
            var text_jq = $('.akit-panel-text',dom_jq).html(spec.assignment);
            MathJax.Hub.Queue(["Typeset", MathJax.Hub, text_jq[0]]);
            $('.akit-button-solve', dom_jq).click(function() {
                $(this).css('display','none');
                spec.solveHandler();
            });
            $('.akit-button-repeat', dom_jq).click(function() {
                spec.repeatHandler();
            });
        },
        //spec.dom
        //spec.wkstep
        showDerivation: function(spec) {
            new StepPanel(spec.wkstep, spec.dom);
        },
        
        setOutput: function(step) {
            var output_jq = $('.akit-output', dom_jq);
            var output = new StepPanel(step, output_jq);
        }
    };
});
