jQuery(function(){
  $('#user_profile_image').on('change', function(){
    let selector = $('#profile-image-preview');
    let file = this.files[0];
    let reader = new FileReader();

    if (file) {
      reader.readAsDataURL(file); //imageファイルをURLの文字列に変更している。
    } else {
      selector.src = "";
    }

    reader.onloadend = function(){
      selector.attr('src', reader.result);
    }
  });
});

