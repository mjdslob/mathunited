/* 
 * Copyright (C) 2013 AlgebraKIT <info@algebrakit.nl>
 *
 */

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery','akit/WKStep'], function ($, WKStep) {
//    var engineUrl = 'http://mathunited.pragma-ade.nl:41080/AKIT_RemoteServer/Main';
//    var engineUrl = 'http://localhost/AKITServer/Main';
//    var engineUrl = '/AKITServer/Main';
    var engineUrl = 'http://akit-server-2014.appspot.com/Main';
    var engineVersionUrl = 'http://{VERSION}.akit-server-2014.appspot.com/Main';
    function variablesToString(varr) {
        if (!varr)
            return '{}';
        var str = '{';
        var first = true;
        for (var name in varr) {
            if (varr.hasOwnProperty(name)) {
                var def = varr[name];
                if (first)
                    first = false;
                else
                    str += ',';
                str += name + ':=' + def.definition;
            }
        }
        str += '}';
        return str;
    }
    ;

    return {
        //setExerciseFn: callback to provide exercise data. Necessary as communication is asynchrounous.
        getExercise: function (audience, exercisePrefix, setExerciseFn) {
            var date = new Date();
            if (exercisePrefix) {
                var params = 'cmd=getrandomassignment&asm=' + exercisePrefix + '&audience=' + audience + '&nocache=' + date.toString();
            } else {
                var params = 'cmd=getrandomassignment&audience=' + audience + '&nocache=' + date.toString();
            }
            $.get(engineUrl, params,
                    function (data) {
                        //data = JSON.parse(data);
                        var exIntro = data.asm;
                        exIntro = exIntro.replace(/"/g, '"');
                        setExerciseFn({
                            intro: exIntro,
                            outExpression: data.out
                        });
                    }
            );
        },
        executeScript: function (script, audience, callback) {
            var params = 'cmd=execute&script=' + encodeURIComponent(script) + '&audience=' + audience;
            $.post(engineUrl, params,
                    function (data) {
                        //data = JSON.parse(data);
                        callback(data);
                    }
            );
        },
        processExpression: function (expr, audience, attributes) {
            var params = 'cmd=solve&exp=' + encodeURIComponent(expr) + '&audience=' + audience;
            if (attributes)
                params += '&attributes=' + attributes;
            var promise = $.post(engineUrl, params)
                    .then(function(data){
                        var step = new WKStep.Step(data);
                        return step;
                    });
            return promise;
        },
        selectAssignmentFromPath: function(path, audience) {
            var params = 'cmd=selectassignment_frompath&path=' + encodeURIComponent(path) + '&audience=' + audience;
            var promise = $.post(engineUrl, params);
            return promise;
        },
        /**
         * spec:
         * - inputExpression: student input in AsciiMathML
         * - template       : conversion template from input to command
         * - orgExpression  : exercise expression in AlgebraKIT-syntax
         * - variables      : array of variable definitions for this exercise
         * - audience 
         * - mode           : solution mode for algebrakit
         * - attributes     : string
         * - callback       : callback after evaluation: function(data), where data is response of server
         */
        checkAnswer: function (spec) {
            var params = 'cmd=evaluate&expression=' + encodeURIComponent(JSON.stringify(spec.expression))
                    + '&model=' + encodeURIComponent(JSON.stringify(spec.model));

            if (spec.state)
                params += '&state=' + encodeURIComponent(JSON.stringify(spec.state));
            if (spec.key)
                params += '&derivationKey=' + encodeURIComponent(JSON.stringify(spec.key));
            var url = engineUrl;
            if (spec.akitVersion)
                url = engineVersionUrl.replace("{VERSION}", spec.akitVersion);
            $.post(url, params,
                    function (data) {
                        spec.callback(data);
                    }
            ).fail(function () {
                alert('Er is een fout opgetreden');
            });
            ;
        },
        //note: audience is not used
        /**
         * spec:
         * - orgExpression  : exercise expression in AlgebraKIT-syntax
         * - variables      : array of variable definitions for this exercise
         * - audience 
         * - attributes     : string
         * - callback       : callback after evaluation: function(data), where data is response of server
         */
        getHint: function (spec) {
            var params = 'cmd=gethint&model=' + encodeURIComponent(JSON.stringify(spec.model));
            if (spec.state)
                params += '&state=' + encodeURIComponent(JSON.stringify(spec.state));
            if (spec.cell) {
                params += '&derivationKey=' + encodeURIComponent(JSON.stringify(spec.cell.key));
            }

            var url = engineUrl;
            if (spec.akitVersion)
                url = engineVersionUrl.replace("{VERSION}", spec.akitVersion);
            $.post(url, params,
                    function (data) {
                        spec.callback(data);
                    }
            );
        },
        /** spec:
         *      expression 
         audience 
         answer 
         variables 
         mode 
         attributes 
         akitVersion
         */
        getSolutionModelFromExpr: function (spec) {
            var params = 'cmd=getsolutionmodel_fromexpr&audience=' + spec.audience
                    + '&expression=' + encodeURIComponent(spec.expression);
            if (spec.answer)
                params += '&answer=' + encodeURIComponent(JSON.stringify(spec.answer));
            if (spec.mode)
                params += '&mode=' + spec.mode;
            if (spec.attributes)
                params += '&tags=' + spec.attributes;
            if (spec.akitVersion)
                params += '&akit-version=' + spec.akitVersion;
            if (spec.variables)
                params += '&variables=' + encodeURIComponent(variablesToString(spec.variables));
            var url = engineUrl;
            if (spec.akitVersion)
                url = engineVersionUrl.replace("{VERSION}", spec.akitVersion);
            $.post(url, params,
                    function (data) {
//                    data = JSON.parse(data);
                        spec.callback(data);
                    }
            );
        }

    };
}
);



