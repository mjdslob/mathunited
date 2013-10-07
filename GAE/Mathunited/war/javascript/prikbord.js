$(document).ready(function(){
	var storageHost = 'http://m4a-storage.appspot.com/get-item?id={ID}'
    var comp=$('#contents').attr('comp');
    var subcomp=$('#contents').attr('subcomp');
    $.ajax({
//    	type: "GET", url:'http://m4a-storage.appspot.com/get-items?ref='+ref,
    	type: "GET", url:'/storage?cmd=get-items&comp='+comp+'&subcomp='+subcomp,
    	success: function(data,textStatus, jqXHR) {
    	    var parent = $('#contents');
    	    $(data).find('item').each(function() {
    	    	var likes = $(this).attr('likes');
    	    	var descr = $(this).children('description').text();
    	    	var type = $(this).children('type').text();
    	    	var user = $(this).children('user').text();
    	    	var key = $(this).children('key').text();
    	    	parent.append('<div class="prikbord-item"><div class="item-name">'+descr+'</div>'
    	    			+'<div class="item-type">'+type+'</div>'
    	    			+'<div class="item-user">'+user+'</div>'
    	    			+'<a class="item-key-link" href="'+storageHost.replace('{ID}',key)+'">downloaden</a>'
    	    			+'<div style="clear:both"></div>');
    	    });
    	}
    });
    
 });

function showNewItemDialog() {
    var comp=$('#contents').attr('comp');
    var subcomp=$('#contents').attr('subcomp');
	var src = "http://m4a-storage.appspot.com/new-item?comp="+comp+'&subcomp='+subcomp;
	$.modal('<iframe src="' + src + '" height="420" width="780" style="border:0">', {
	    closeHTML:"",
	    containerCss:{
	        backgroundColor:"#fff",
	        borderColor:"#fff",
	        height:450,
	        padding:0,
	        width:830,
	        maxWidth:800
	    },
	    overlayClose:true
	});	
}
