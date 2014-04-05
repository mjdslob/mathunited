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
   return {
       parse: function(xml,parent, thisStepId, nextStepId) {
            this.parent = parent;
            if(xml.nodeType===9) xml = xml.childNodes[0]
            //take care of highlighting of subexpressions
            if(nextStepId > 0 || thisStepId>0) this.highlight(xml,thisStepId, nextStepId);
            //embed the xml into the html page, by first converting it to string
            var htmlstr = this.convert2HTML(xml);
            parent.innerHTML = '<div style="display:none">&nbsp;</div>'+htmlstr;
            //call script functions that may be defined
            var elms = $('.loadScript',parent);
            this.loadScriptCount = 0;
            
            if(elms && elms.length>0) {
              var thisInstance = this;
              for(var ii=0; ii<elms.length;ii++) {
                   this.loadScriptCount++;
                   loadScript(elms[ii],function(){thisInstance.continueParsing();});
              }
            } else {
               this.continueParsing();
            }
       },
       highlight: function(elm, thisId, nextId){
            if(elm.tagName=='mrow') {
                var att = elm.getAttribute('pbase');
                if(att!=null && att==nextId) {
                    elm.tagName = 'mstyle';
                    elm.setAttribute("color","#aa0000");
                }
                /*
                att = elm.getAttribute('pout');
                if(att!=null && att>=thisId && att<nextId) {
                    elm.tagName = 'mstyle';
                    elm.setAttribute("color","#aa0000");
                }
                */
            }
            if(elm.childNodes) {
                for(var ii=0; ii<elm.childNodes.length;ii++){
                    this.highlight(elm.childNodes[ii], thisId, nextId);
                }
            }
       },
       parseFromHTML: function(htmlstr,parent) {
            this.parent = parent;
            parent.innerHTML = htmlstr;
            //call script functions that may be defined
            var elms = $('.loadScript',parent);
            this.loadScriptCount = 0;
            if(elms && elms.length>0) {
              var thisInstance = this;
              for(var ii=0; ii<elms.length;ii++) {
                   this.loadScriptCount++;
                   loadScript(elms[ii],function(){thisInstance.continueParsing();});
              }
            } else {
               this.continueParsing();
            }
       },
       continueParsing: function() {
            if(this.loadScriptCount>1) {
               this.loadScriptCount--;
               return;
            }
            try{
         //     this.jmath_convert(this.parent);
               MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
            } catch(e) {
           }

       },
       convert2HTML: function(node) {
            switch(node.nodeType) {
               case 1: //element
                    var skipNode = false;
                    if(node.nodeName=='text'){
                        skipNode=true;
                    }
                    if(!skipNode)
                       var result = '<'+node.nodeName;
                   else
                       var result = '';
                    if(node.attributes && node.attributes.length>0) {
                        var attrs = node.attributes;
                        for(var ii=0; ii<attrs.length;ii++) {
                            var a = attrs.item(ii);
                            result += ' '+a.nodeName+'="'+a.value+'"';
                        }
                    }
                    if(!skipNode)
                       result += '>';
                    if(node.childNodes && node.childNodes.length>0){
                       for(ii=0; ii<node.childNodes.length;ii++) {
                           var n = node.childNodes[ii];
                           result += this.convert2HTML(n);
                       }
                    }
                    if(!skipNode)
                       result += '</'+node.nodeName+'>';
                    break;
               case 3: //text
               case 4:
                    if(node.textContent)
                       result = node.textContent;
                    else
                       result = node.text;
                    //result = ' '+result+' ';
                    break;
           }
           return result;
        }
        
       
   };
});