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
        
        checkAnswer: function(inputExpression, submitTemplate, orgExpression, answer, mode, audience, solutionAttributes, callback) {
            var params = 'cmd=check&inputExpression='+encodeURIComponent(inputExpression)
                    +'&orgExpression='+encodeURIComponent(orgExpression)
                    +'&audience='+audience+'&syntax=AM';
            if(answer) params += '&answer='+encodeURIComponent(answer);
            if(mode)   params += '&mode='+mode;
            if(submitTemplate) params += '&template='+encodeURIComponent(submitTemplate);
            if(solutionAttributes) params+='&attributes='+encodeURIComponent(solutionAttributes);
            $.post(engineUrl, params, 
                   function(data) {
                        //data = JSON.parse(data);
                        callback(data);
                   }
            ).fail(function(){alert('Er is een fout opgetreden');});;
            
        },

        //note: audience is not used
        getHint: function(orgExpression, audience, solutionAttributes, callback) {
            var params = 'cmd=gethint&orgExpression='+encodeURIComponent(orgExpression)+'&audience='+audience;
            if(solutionAttributes) params+='&attributes='+encodeURIComponent(solutionAttributes);
            $.post(engineUrl, params, 
                   function(data) {
                        //data = JSON.parse(data);
                        callback(data);
                   }
            );
            
        }
        
    };
  }
);



