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

define(['jquery', 'app/Document','actions/ObjectivesHandler', 'actions/SetExerciseMetadata', 
        'app/ItemSelector',  'actions/AlgebraKITSpecHandler', 'jqueryui'], 
 function($, doc, objectivesHandler, metadataHandler, itemSelector, AlgebraKITSpecHandler) {
    var commitURL = '/MathUnited/postcontent';
    var refreshURL = '/MathUnited/refresh-lock';
    
    /*
    //utility plugin to prevent automatic zooming on double tap on iPhone
    //note: does not work on Android (unless using Chrome)!
    (function($) {
      $.fn.nodoubletapzoom = function() {
          $(this).bind('touchstart', function preventZoom(e) {
            var fingers = e.originalEvent.touches.length;
            if (fingers > 1) return; // not double-tap

            e.preventDefault(); // double tap - prevent the zoom
            // also synthesize click events we just swallowed up
            $(this).trigger('click');
          });
      };
    })($);
    */
    window.onbeforeunload = function() {
      if(doc.isChanged()){
         return "Wijzigingen die u niet heeft opgeslagen gaan verloren.";
      }
    };
    

    var baseRepoPath = $('#meta-data-baserepo-path').text();
    var repoPath     = $('#meta-data-repo-path').text();
    var comp     = $('#meta-data-comp').text();
    var subcomp  = $('#meta-data-subcomp').text();
    var refbase  = $('#meta-data-refbase').text();
    
    function refreshLock() {
        $.get(refreshURL, {refbase: refbase}, 
            function(data) {
                if( $(data).children().first().attr('success')==='true') {
                    setTimeout(refreshLock, 30000);
                } else {
                    alert('Er is een probleem opgetreden: kan lock op de paragraaf niet verversen.');
                }
            }
        );
    }

    if(doc.isLocked()) alert($('#locked-message').text().replace(/\s+/g,' '));
    else {
        //start loop to refresh lock
        setTimeout(refreshLock, 30000);
    }
    
    return {
        isTouchDevice: ("ontouchstart" in document.documentElement),
        getComp      : function() {return comp;},
        getSubcomp   : function() {return subcomp;},
        getRepoPath      : function() {return repoPath;},
        getBaserepoPath  : function() {return baseRepoPath;},
        getRefbase   : function() {return refbase;},
        getImagebase : function() {
                            var imagebase = refbase;//contentbase+refbase;
                            var ind = imagebase.lastIndexOf('/'); //2 times, because of trailing /
                            imagebase = imagebase.substr(0,ind);
                            var ind = imagebase.lastIndexOf('/');
                            imagebase = imagebase.substr(0,ind)+'/images/highres';
                            return imagebase;
                       },
        init: function() {
            var _this = this;
            objectivesHandler.init();
            itemSelector.init( $('#meta-components-url').text(), $('#meta-threads-url').text() );
            AlgebraKITSpecHandler.init();
            doc.init();
            $('#commit-button').click(function(){_this.submit();});
            $('#show-backups-wrapper').click(function(){_this.showBackups();});
            $('#startup-msg').remove();
            $('div[tag="exercise"]').each( function(){
                var base = $(this).parents('div[tag="include"]').first();
                metadataHandler.setExerciseIcons(base);
            });
        },
        submit: function() {
            $('<p>Een moment, de paragraaf wordt opgeslagen...</p>').dialog();
            //save all edits in open editors first
            doc.prepareForSubmit();
            
            var status = $('#workflow-container input:checked').val();
            var html = $('.editorDiv').first().html();
            var nItems = $('div[tag="include"]').length; //used to check if all items are saved
            var str = repoPath+'\n'+comp+'\n'+subcomp+'\n'+status+'\n'+nItems+'\n'+html;
        //    html = encodeURIComponent(html);
            $.post(commitURL, str,
                function(data) {//on success
                    if($('post',data).attr('result')!=="true") {
                        var msg = $('post message',data).text();
                        alert('Fout bij opslaan van het document: '+msg);
                    } else {
                        doc.setChanged(false);
                        location.reload();
                    }
                });
            
        },
        showBackups: function() {
            $.get('/MathUnited/backuplist', {comp:comp, subcomp:subcomp}, 
                  function(xml) {
                      xml = $(xml);
                      var text='';
                      var isChanged = doc.isChanged();
                      if(isChanged){
                          text = '<p style="color:red">Let op: u heeft mogelijk wijzigingen gemaakt die nog niet zijn opgeslagen. Deze wijzigingen verliest u als u een backup terugzet.</p>';
                      } 
                      var html = '<div><p style="margin-bottom:10px">Selecteer een backup uit onderstaande tabel. De onderste regel is de versie die u het laatst heeft opgeslagen.</p>'
                             +text + '<table class="log-overview"><tr><th>Auteur</th><th>Datum</th><th>Tijd</th></tr>';
                      $('log',xml).each(function() {
                          var entry = $(this);
                          var str = entry.text();
                          if(str.indexOf(subcomp)>0){
                            str = str.replace(/^[^_]*_/,'');
                            var date = str.match('20[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]');
                            var time = str.match('[0-9][0-9]\.[0-9][0-9]\.[0-9][0-9]\.zip$');
                            if(time.length>0) time=time[0].replace('.zip','');
                            html+='<tr class="log-entry" entry="'+entry.text()+'"><td>'+entry.attr('user')+'</td><td>'+date+'</td><td>'+time+'</td></tr>';
                          }
                      });
                      html+="</table></div>";
                      var dom = $(html);
                      $('.log-entry',dom).click(function(){
                          var doChange = !doc.isChanged();
                          if(isChanged){
                            doChange=false;
                            var r=confirm('U heeft wijzigingen gemaakt in uw document. Als u deze backup terugzet, dan gaan die verloren. Weet u zeker dat u de backup wilt terugzetten?');
                            if(r===true) doChange = true;
                          }
                          if(doChange) {
                              $.get("/MathUnited/restorebackup",
                              {comp: comp, subcomp: subcomp, entry: encodeURIComponent($(this).attr('entry')) },
                              function(data) {
                                  doc.setChanged(false);
                                  window.location.reload();
                              });
                          }
                      });
                      dom.dialog({width:400, height:400, title:'Backup terugplaatsen'});
                  });
            
        }
    };
  }
);



