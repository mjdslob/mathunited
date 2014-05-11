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
    var PRIORITY_POWER = 30;
    var PRIORITY_TIMES = 20;
    var PRIORITY_PLUS = 10;
    var PRIORITY_MIN = 0;
    
    return {
        transformMML : function(elm, priority) {
            if(elm.nodeType===3) return '';
            var name = elm.nodeName.toLowerCase();
            var result = '';
            switch(name) {
                case 'math' : result = '`'+this.transformMML(elm.childNodes[0], PRIORITY_MIN)+'`'; break;
                case 'mstyle' : result = this.transformMML(elm.childNodes[0], priority); break;
                case 'mi' : result = ' '+$(elm).text(); break;
                case 'mn' : result = ' '+$(elm).text(); break;
                case 'mo' : 
                    result = ' '+$(elm).text(); 
                    break;
                case 'mfrac': 
                    if(priority>PRIORITY_TIMES){
                        result = '('+this.transformMML(elm.childNodes[0],PRIORITY_TIMES)+'/'+this.transformMML(elm.childNodes[1],PRIORITY_TIMES)+')';
                    } else {
                        result = this.transformMML(elm.childNodes[0],PRIORITY_TIMES)+'/'+this.transformMML(elm.childNodes[1],PRIORITY_TIMES);
                    }
                    break;
                case 'msup': 
                    var c1 = $(elm).children()[0];
                    var c2 = $(elm).children()[1];
                    if(priority>PRIORITY_POWER){
                        result = '('+this.transformMML(c1,PRIORITY_POWER)+'^'+this.transformMML(c2,PRIORITY_POWER)+')'; 
                    } else {
                        result = this.transformMML(c1,PRIORITY_POWER)+'^'+this.transformMML(c2,PRIORITY_POWER); 
                    }
                    break;
                case 'mrow' :
                    var chlds = $(elm).children();
                    var putBrackets = false;
                    var newPrio = priority;
                    if(chlds.length>1 && priority>PRIORITY_PLUS) {putBrackets = true;newPrio=PRIORITY_PLUS;}
                    if(putBrackets) result = '('; else result = '';
                    for(var ii=0; ii<elm.childNodes.length; ii++) {
                         result = result+this.transformMML(elm.childNodes[ii],newPrio);
                    }
                    if(putBrackets) result = result+')';
                     break;
                case 'mfenced' :
                     result = '(';
                     for(var ii=0; ii<elm.childNodes.length; ii++) {
                         result = result+this.transformMML(elm.childNodes[ii],PRIORITY_MIN);
                     }
                     result = result + ')';
                     break;
                 case 'mspace' : result = '\ '; break;
                 case 'mroot' : 
                    var c1 = $(elm).children()[0];
                    var c2 = $(elm).children()[1];
                    result = 'root'+this.transformMML(c2,PRIORITY_POWER)+this.transformMML(c1,PRIORITY_POWER);
                    break;
                 case 'msqrt' : 
                    var c1 = $(elm).children()[0];
                    result = 'sqrt'+this.transformMML(c1,PRIORITY_POWER);
                    break;
                case 'mpadded': 
                    var chlds = $(elm).children();
                    var putBrackets = false;
                    var newPrio = priority;
                    if(chlds.length>1 && priority>PRIORITY_PLUS) {putBrackets = true;newPrio=PRIORITY_PLUS;}
                    if(putBrackets) result = '('; else result = '';
                    for(var ii=0; ii<elm.childNodes.length; ii++) {
                         result = result+this.transformMML(elm.childNodes[ii],newPrio);
                    }
                    if(putBrackets) result = result+')';
                    break;
                case 'msubsup':
                    var c1 = $(elm).children()[0];
                    var c2 = $(elm).children()[1];
                    var c3 = $(elm).children()[2];
                    result = this.transformMML(c1,priority)+'_'+this.transformMML(c2,priority)+'^'+this.transformMML(c3,priority);
                    break;
                default: result = '#?'+name+'#?'; break;
            }
            return result; 
        },
        transformSingle : function(elm) {
            if(elm.nodeType===3) return elm.nodeValue;
            if(elm.nodeType===4) return elm.nodeValue;
            var name = elm.nodeName.toLowerCase();
            switch(name) {
                case 'math' : return this.transformMML(elm, PRIORITY_MIN); break;
                case 'p' : 
                    if(elm.childNodes.length>0) 
                        return '<p>'+this.transform($(elm.childNodes))+'</p>'; 
                    else 
                        return '';
                    break;
                case 'span':
                    if(elm.childNodes.length>0) 
                        return this.transform($(elm.childNodes)); 
                    else 
                        return '';
                    break;
                case 'mstyle': return this.transform($(elm.childNodes)); break;
                case 'text':   return this.transform($(elm.childNodes)); break;
                default: 
                    return '<span>#?? '+name+'??#</span>'; break;
            }
        },
        transform: function(jq_elm) {
            //return jq_elm.html();
            var _this = this;
            if(jq_elm.length===0) return '';
            var result = '';
            for(var ii=0; ii<jq_elm.length; ii++){
                result = result + _this.transformSingle( jq_elm[ii] );
            }
            return result;
        }
        
    };
  }
);



