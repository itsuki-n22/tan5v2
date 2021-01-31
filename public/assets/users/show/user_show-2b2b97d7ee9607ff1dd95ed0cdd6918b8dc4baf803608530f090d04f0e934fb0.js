$(document).on('click','#add-tango-btn',function(){
  $('#create-tango-form').fadeIn();
});

$(document).on('click','#build-wordnote-btn',function(){
  $('#create-wordnote-form').fadeIn();
});
  
$(document).on('click','#create-tango-form .modal-close, #create-wordnote-form .modal-close',function(){
  $('.modal').fadeOut();
});
