define(['jquery', 'mathjax', 'jqueryui'], function ($) {
   
    var WIDGET_HTML = 
         '<div class="akit-container">'
        +'   <div class="akit-logo"></div>'
        +'   <div class="akit-panel">'
        +'     <div class="akit-instruction-text"></div>'
        +'     <div class="akit-assignment-expr"></div>'
        +'     <div class="akit-button akit-button-repeat"></div>'
        +'     <div class="akit-button akit-button-solve"></div>'
        +'   </div>'
        +'   <div class="akit-output">'
        +'   </div>'
        +'</div>';

    var dom_jq;
    var repeat_jq, solve_jq;
    var obj;
    return obj = {
        //dom: root node to contain the trainer frontend
        init: function(spec) {
            var self = this;
            dom_jq = spec.dom;
            dom_jq.append($(WIDGET_HTML));
            $('.akit-instruction-text',dom_jq[0]).html(AlgebraKIT.elements2html(spec.view.instruction));
            $('.akit-assignment-expr',dom_jq[0]).html(AlgebraKIT.elements2html(spec.view.assignment));
            AlgebraKIT.render(dom_jq[0]);
            solve_jq = $('.akit-button-solve', dom_jq).click(function() {
                obj.solve(spec.exerciseSpec);
            });
            repeat_jq = $('.akit-button-repeat', dom_jq).click(function() {
                spec.repeatHandler();
            });
        },
        repeat: function(spec) {
            $('.akit-instruction-text',dom_jq[0]).html(AlgebraKIT.elements2html(spec.view.instruction));
            $('.akit-assignment-expr',dom_jq[0]).html(AlgebraKIT.elements2html(spec.view.assignment));
            $('.akit-output', dom_jq).html('');
            solve_jq.css('display','block');
            solve_jq.unbind('click').click(function() {
                obj.solve(spec.exerciseSpec);
            });
            AlgebraKIT.render(dom_jq[0]);
        },
        //spec.dom
        //spec.wkstep
        solve: function(spec) {
            solve_jq.css('display','none');
            var solve = spec.solve?spec.solve:spec.assignment;
            $('.akit-output', dom_jq).html('<akit-derivation solve="'+solve+'" audience="'+spec.audience+'" modes="'+spec.modes.join(",")+'" expanded="true"></akit-derivation>');
            AlgebraKIT.injectWidgets($('akit-derivation', dom_jq)[0]);
        },
        
        setOutput: function(step) {
            var output_jq = $('.akit-output', dom_jq);
            var output = new StepPanel(step, output_jq);
        }
    };
});
