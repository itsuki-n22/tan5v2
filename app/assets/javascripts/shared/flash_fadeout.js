// 全てのflashを自動でfadeOutするようにしている。
flashCloseInterval = setInterval(function(){ 
  $('#flash-message').find(".alert").fadeOut(1000)
}, 3000);
