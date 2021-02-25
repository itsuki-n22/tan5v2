/// show wordnote config panel
let changedFlagForWordnote = false;
$(document).on('click','[id*="edit-no-"]',function(){
  $('#edit-wordnote-window').fadeIn();
  let editList = $(this).siblings();
  let wordnoteId = $(this).attr("id").split("-").pop();
  $('#edit_wordnote_id').val(wordnoteId)
  $.each(editList,function(){
    let name = $(this).attr("name").replace(/-\d+/,"");
    let val = $(this).attr("value")
    if (val){
      if (name == "is_open"){
        if(val == "true"){
          $('#is_open').prop('checked', true);
        }else{
          $('#is_open').prop('checked', false);
        };
      }else{
        $('#' + name).val(val);
      }
    };
  });

  ///csv url
  dl_url = '/wordnotes/' + $('#edit_wordnote_id').val() +  '/tangos.csv'
  $('.download-csv').attr('href',dl_url)
  ul_url = '/wordnotes/' + $('#edit_wordnote_id').val() +  '/tangos/import'
  delete_url = '/wordnotes/' + $('#edit_wordnote_id').val() +'?user_id=' + $('#current_user_id').val()
  $('.upload-csv').attr('href',ul_url)
  $('.upload-csv').attr('action',ul_url)
  $('#delete-wordnote-btn').attr('href',delete_url)
});

/// detail-btn to show csv btns and delete btn
$(document).on("click", '#wordnote-detail-show-btn', function(){ 
  $('#csv-control-panel, #wordnote-delete-btn').removeClass("hidden")
  $(this).addClass("hidden");
})

///if change parameter 
$(document).on({
  'mouseenter' : function(){
    $('#csv-upload-explain').removeClass("hidden")
  },
  'mouseleave' : function(){
    $('#csv-upload-explain').addClass("hidden")
  }
 },'#csv-upload-explain-trigger')

$(document).on('change','#edit-wordnote-window .edit-item',function(){
  changedFlagForWordnote = true;
  let id = $(this).attr("id");
  let val = $(this).val();
  let params = {wordnote: {}};
  if(id == "is_open"){ 
    if($('input.edit-item:checked').prop("checked")){
      val = true
    };
  };
  params["wordnote"][id] = val;
  editWordnote(params);
});

/// modal close
$(document).on('click','#edit-wordnote-window .modal-close',function(){
  if( changedFlagForWordnote == true){
    $('#edit-wordnote-form').html('<p>適用中...</p>');
    location.reload();
  }else{
    $('.modal').fadeOut();
  };
});

/// update config data by ajax
function editWordnote(editWordnoteParams){
  $.ajax({
      url: '/wordnotes/' + $('#edit_wordnote_id').val(),
      type: "PATCH",
      data: editWordnoteParams,
      dataType: "text",
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token',$('meta[name="csrf-token"]').attr('content'));
      },
  });
};
