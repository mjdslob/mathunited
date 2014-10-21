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
    //private space
    var OMOperatorMap = {
        divide: {akitName: 'division'},
        plus:   {akitName: 'plus'},
        power:   {akitName: 'power'},
        root:   {akitName: 'sqrt',
                 fnc: function(chlds) {
                     var x = transformOMNodeToAKIT($(chlds[1]));
                     var m = transformOMNodeToAKIT($(chlds[2]));
                     if(m==='2') return 'sqrt['+x+']';
                     else return 'sqrt['+x+','+m+']';
                 }
        },
        minus:   {akitName: 'minus',
                      fnc: function(chlds) {
                          return transformOMNodeToAKIT($(chlds[1]))+'-('+transformOMNodeToAKIT($(chlds[2]))+')';
                      } 
                 },
        times:  {akitName: 'times'},
        eq:     {akitName: 'Equals'},
        lt:     {akitName: 'Smaller'},
        leq:     {akitName: 'SmallerEqual'},
        gt:     {akitName: 'Greater'},
        geq:     {akitName: 'GreaterEqual'},
        or:     {akitName: 'Or'},
        and:     {akitName: 'And'},
        rational: {akitName: 'Rational',
                   fnc: function(chlds) {
                       var num = transformOMNodeToAKIT($(chlds[1]));
                       var breuk = $(chlds[2]);
                       var cc = breuk.children();
                       var teller = transformOMNodeToAKIT($(cc[1]));
                       var noemer = transformOMNodeToAKIT($(cc[2]));
                       var sgn = 1;
                       if(parseInt(teller)<0) sgn = -1;
                       return 'Rational['+sgn+','+num+','+teller+','+noemer+']';
                   }
               },
        unary_minus: 
                {akitName: '-', 
                      fnc: function(chlds) {
                          return '-'+transformOMNodeToAKIT($(chlds[1]));
                      } 
                  },
        sin:  {akitName: 'sin'},
        cos:  {akitName: 'cos'},
        tan:  {akitName: 'tan'},
        diff: {akitName: 'Diff'}
    }
    function transformOMNodeToAKIT(omNode) {
        var akitStr='';
        switch(omNode[0].nodeName) {
            case 'OMOBJ':
                akitStr = transformOMNodeToAKIT(omNode.children().first());
                break;
            case 'OMA':
                var chlds = omNode.children();
                var symbol = transformOMNodeToAKIT(chlds.first());
                if(OMOperatorMap.hasOwnProperty(symbol)){
                    var ss = OMOperatorMap[symbol];
                }
                if(!ss) alert('unknown OpenMath symbol: '+symbol);
                if(ss.hasOwnProperty('fnc')) {
                    akitStr = ss.fnc(chlds);
                } else {
                    symbol = ss.akitName;
                    akitStr = symbol+'['+transformOMNodeToAKIT($(chlds[1]));
                    for(var ii=2; ii<chlds.length;ii++) {
                        akitStr = akitStr + ',' + transformOMNodeToAKIT($(chlds[ii]));
                    }
                    akitStr += ']'
                }
                break;
            case 'OMS':
                akitStr = omNode.attr('name');
                break;
            case 'OMF':
                akitStr = omNode.attr('dec');
                break;
            case 'OMV':
                akitStr = omNode.attr('name');
                break;
            case 'OMI':
                akitStr = omNode.text();
                break;
            case 'OME':
                throw "De invoer bevat een fout. ";

        }
        return akitStr;
    }
    return {
        //translate openmath into algebrakit expression
        OMtoAKIT : function(omStr) {
            omDoc = $.parseXML(omStr);
            var node = $('OMOBJ', omDoc);
            return transformOMNodeToAKIT(node);
        }
    };
    });

