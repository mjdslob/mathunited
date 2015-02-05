MU_Util = {
    //read parameters in url
    //example:    var id = MU_Util.URLParam('contentsetID');
    URLparam : function( name ){
      name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
      var href = window.location.href.replace('%20',' ');
      var regexS = "[\\?&]"+name+"=([^&#]*)";
      var regex = new RegExp( regexS );
      var results = regex.exec( href );
      if( results == null )
        return "";
      else
        return results[1];
    }

};
