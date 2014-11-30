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

//This is a stub for the actual AlgebraKIT-engine which runs on the server.
define(['jquery'], function($) {
//    var engineUrl = 'http://mathunited.pragma-ade.nl:41080/AKIT_RemoteServer/Main';
//    var engineUrl = 'http://localhost/AKIT_RemoteServer/Main';
    var engineUrl = '/AKIT_RemoteServer/Main';
    
    function variablesToString(varr) {
        if(!varr) return '{}';
        var str = '{';
        var first = true;
        for(var name in varr) {
            if(varr.hasOwnProperty(name)) {
                var def = varr[name];
                if(first) first = false; else str+=',';
                str+=name+':='+def.definition;
            }
        }
        str+='}';
        return str;
    };
    
    return {
        //setExerciseFn: callback to provide exercise data. Necessary as communication is asynchrounous.
        getExercise: function(audience, exercisePrefix, setExerciseFn) {
            var date = new Date();
            if(exercisePrefix){
                var params = 'cmd=getrandomassignment&asm='+exercisePrefix+'&audience='+audience+'&nocache='+date.toString();
            } else {
                var params = 'cmd=getrandomassignment&audience='+audience+'&nocache='+date.toString();
            }
            $.get(engineUrl, params, 
                   function(data) {
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
        executeScript: function(script,audience, callback) {
            var params = 'cmd=execute&script='+encodeURIComponent(script)+'&audience='+audience;
            $.post(engineUrl, params, 
                   function(data) {
                        //data = JSON.parse(data);
                        callback(data);
                   }
            );
            
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
        checkAnswer: function(spec) {
            var params = 'cmd=check&inputExpression='+encodeURIComponent(spec.inputExpression)
                    +'&orgExpression='+encodeURIComponent(spec.orgExpression)
                    +'&audience='+spec.audience+'&syntax=AM'+'&variables='+encodeURIComponent(variablesToString(spec.variables));
            if(spec.answer) params += '&answer='+encodeURIComponent(spec.answer);
            if(spec.mode)   params += '&mode='+spec.mode;
            if(spec.template) params += '&template='+encodeURIComponent(spec.template);
            if(spec.solutionAttributes) params+='&attributes='+encodeURIComponent(spec.solutionAttributes);
            
            $.post(engineUrl, params, 
                   function(data) {spec.callback(data);}
            ).fail(function(){alert('Er is een fout opgetreden');});;
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
        getHint: function(spec) {
            var params = 'cmd=gethint&orgExpression='+encodeURIComponent(spec.orgExpression)+'&audience='+spec.audience+'&variables='+encodeURIComponent(variablesToString(spec.variables));
            if(spec.solutionAttributes) params+='&attributes='+encodeURIComponent(spec.solutionAttributes);
            $.post(engineUrl, params, 
                   function(data) {
                        //data = JSON.parse(data);
                        spec.callback(data);
                   }
            );
            
        }
        
    };
  }
);



