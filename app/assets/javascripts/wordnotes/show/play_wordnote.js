jQuery(function($){
  let fontSize = $('[name*="font_size-"]').val();$
  $('#learn-wrapper').css({'font-size': Number(fontSize)});$
  let interval = Number($('[name*="timer-"]').val());$
  let lastQuestion = Number( $('[id*="last_question"]').val() );
  let isContinue =  $('[id*="continue-"]').val() ;
  let tangoNumber = 0;
  let tangoArray = [];
  let tangoData = $('#questions').find('tr');
  for(let n = 1; n < tangoData.length ; n++){
    let ans = tangoData.eq(n).find('td').eq(3).text();
    let que = tangoData.eq(n).find('td').eq(2).text();
    let hint = tangoData.eq(n).find('td').eq(4).text();
    let tangoId = tangoData.eq(n).find('td').eq(1).text();
    tangoArray.push({answer: ans, question: que, hint: hint, tangoId: tangoId});
    if(lastQuestion > 0 && tangoId == lastQuestion && isContinue == "true"){tangoNumber = n - 1};
  };
  tangoArray.pop();
  let questionHtml = $('#question-text');
  let answerHtml = $('#answer-text');
  let questionBoxHtml = $('#question');
  let answerBoxHtml = $('#answer');
  let hintHtml = $('#hint-text');
  let tangosHtml = $('#questions');
  let learnHtml = $('#learn-wrapper');
  let correctBtnHtml = $('#correct-btn');
  let wrongBtnHtml = $('#wrong-btn');
  let deleteBtnHtml = $('#delete-btn');
  let hintBtnHtml = $('#hint-btn');
  let showAllTangosHtml = $('#show-tangos');
  let operationHtml = $('#learn-operation');
  showAllTangos();
  setTango();
  operateStatus();

  function changeTangoStatus(){
      if(answerHtml.attr('class') == 'hidden'){
        showAnswer();
      } else if(answerHtml.attr('class') != 'hidden'){
        changeTangoNumber(1);
        setTango();
      };
  };

  function resetTangoArray(){
    tangoArray = [];
    tangoData = $('#questions').find('tr');
    for(let n = 1; n < tangoData.length ; n++){
      let ans = tangoData.eq(n).find('td').eq(3).text();
      let que = tangoData.eq(n).find('td').eq(2).text();
      let hint = tangoData.eq(n).find('td').eq(4).text();
      let tangoId = tangoData.eq(n).find('td').eq(1).text();
      tangoArray.push({answer: ans, question: que, hint: hint, tangoId: tangoId});
    };
    tangoArray.pop();
  };

  //// auto-btn ( timer )
  let questionInterval ;
  let displayInterval;
  let displayCounter = 3;
  if(interval > 0){ 
    displayCounter = interval;
  }
  controlTimer();

  function runTimer(interval){
    $('#auto-btn').addClass('auto-on').html(`<i class="fa fa-stop"></i> (${interval})`);
    questionInterval = setInterval(function(){ //順番重要
      changeTangoStatus();
      displayCounter = interval + 1;
    },interval * 1000);
    displayInterval = setInterval(function(){ //順番重要
      displayCounter--;
      $('#auto-btn').addClass('auto-on').html(`<i class="fa fa-stop"></i> (${displayCounter})`);
    },1000);
  };

  function stopTimer(){
    clearInterval(displayInterval); //順番重要
    clearInterval(questionInterval); //順番重要
    displayCounter = interval;
    $('#auto-btn').removeClass('auto-on').html(`<i class="fa fa-play"></i> play`);
  };

  function resetTimer(){
    if($('#auto-btn').attr('class').match(/auto-on/)){
      stopTimer();
      runTimer(interval);
    }
  }

  function controlTimer(){
    $('#auto-btn').click(function(){
      if($(this).attr('class').match(/auto-on/)){
        stopTimer();
      }else{
        if(interval > 0 ){
        }else{
          interval = 3;
        };
        runTimer(interval);
      }
    });
  };

  function setTango(){
    resetTangoArray();
    getTangoData();
    $('#tango-number').text(String(tangoNumber + 1) + " / " + tangoArray.length);
    answerHtml.addClass('hidden'); 
    answerBoxHtml.addClass('blink'); 
    questionHtml.text(tangoArray[tangoNumber].question);
    answerHtml.html(htmlEscape(tangoArray[tangoNumber].answer).replace(/\n/g,"<br>"));
    hintHtml.text(' ' + tangoArray[tangoNumber].hint);
    wrongBtnHtml.addClass('hidden');
    correctBtnHtml.addClass('hidden');
    wrongBtnHtml.removeClass('blink');
    correctBtnHtml.removeClass('blink');
  }
  function showAnswer(){
    answerHtml.removeClass('hidden');
    answerBoxHtml.removeClass('blink'); 
    wrongBtnHtml.removeClass('hidden');
    correctBtnHtml.removeClass('hidden');
    wrongBtnHtml.addClass('blink');
    correctBtnHtml.addClass('blink');
  }
  
  function showAllTangos(){
    if( $('#current_user_id').val() == $('#user_id').val() ){ 
      showAllTangosHtml.click(function(){
        if(tangosHtml.attr('class').match(/hidden/)){
          tangosHtml.removeClass('hidden');
          showAllTangosHtml.html('<i class="fa fa-window-close"></i> 閉じる');
        } else {
          tangosHtml.addClass('hidden');
          showAllTangosHtml.html('<i class="fa fa-book-open"></i> 問題を全て見る');
        };
      });
    }
  };

  function operateStatus(){
    /// #btn => resetTangoArray
    $('#questions').on('click',"[class*='update-btn'] , [class*='create-btn'], [class*='delete-btn']",function(){
      resetTangoArray();
    });

    /// edit tango
    $(document).on({
      'mouseenter':function(){
        $(this).find("[class*='fa-edit']").removeClass("hidden");
      },
      'mouseleave':function(){
        $(this).find("[class*='fa-edit']").addClass("hidden");
      }
    },"[class='hint'], [class='answer'], [class='question']");

    $(document).on('click',"[id*='tango-no-'] > td > [class*='fa-edit']", function(){
      let td = $(this).parent();
      let attr = $(this).parent().attr('class');
      let value = $(this).parent().text();
      if (!attr){} else if (attr.length > 1){
        $(this).parent().removeClass(attr);
        if (attr == "created_at"){
        }else{
          $(this).parent().siblings().last().find('[class*="created_at-text"]').addClass("hidden");
          $(this).parent().siblings().last().find('[class*="btn"]').removeClass("hidden");
          let textarea = jQuery(jQuery.parseHTML('<textarea style="width:100%;"></textarea>')).attr({
            class: "tango_" + htmlEscape(attr),
            default: htmlEscape(value)
          }).val(value);
          $(this).parent().html(textarea);
          td.find('textarea').height((td.find('textarea').get(0).scrollHeight));
        };
      };
    });

    $("table").on('input',"[id*='tango-no-'] > td > textarea",function(){
      let value = $(this).val();
      let target = "#" + $(this).attr('class');
      $(this).parent().siblings().last().find(target).attr({value: value});
    });

    $("table").on('click',"[class*='update-cancel-btn']",function(){
      $(this).parent().siblings().children("textarea").each(function(){
        let value = $(this).attr('default');
        if (value === undefined){ value = "" }
        value = value + "<i class='fas fa-edit fa-xs ml-1 hidden'></i>";
        let attr = $(this).attr("class").split("_").pop();
        $(this).parent().addClass(attr).html(value);
      });
      
      $(this).parent().find('[class*="created_at-text"]').removeClass("hidden");
      $(this).parent().find('[class*="btn"]').addClass("hidden");
    });

    // create new tango
    $("[id*='create-new-tango']").on('click',"[class*='new-btn']",function(){
      $(this).parent().siblings().find('textarea').removeClass("hidden")
      $(this).parent().siblings().find('[class*="btn"]').removeClass("hidden")
    });

    $("[id*='create-new-tango']").on('input','textarea',function(){
      let value = $(this).val();
      let target = '[name="' + $(this).attr('class') +'"]'
      $(this).parent().siblings().last().find(target).attr({value: value});
    });

    $("[id*='create-new-tango']").on('click',"[class*='create-cancel-btn']",function(){
      $(this).parent().siblings().find('textarea').addClass("hidden")
      $(this).siblings().find('[class*="btn"]').addClass("hidden")
      $(this).addClass("hidden")
    });

    /// save last question
    $(window).on('beforeunload', function() { 
      let lastQuestion = tangoArray[tangoNumber].tangoId;
      let params = {tango_config: {}};
      let tangoConfigId = $('#tango_config_id').val();
      params["tango_config"]["last_question"] = lastQuestion;
       $.ajax({
           url: '/tango_configs/' + tangoConfigId,
           type: "patch",
           data: params,
           dataType: "text",
           beforeSend: function(xhr){
             xhr.setRequestHeader('X-CSRF-Token',$('meta[name="csrf-token"]').attr('content'));
           },
       });
     });

    /// delete checked tangos
    $("table").on('change',"[id*='delete-check-']",function(){
      resetDeleteHiddenField();
    });

    $("[class*='delete-check-all']").on('change',function(){
      if ($(this).prop('checked')){
        $("[id*='delete-check-']").each(function(){
          $(this).prop('checked', true);
        });
      }else{
        $("[id*='delete-check-']").each(function(){
          $(this).prop('checked', false);
        });
      };
      resetDeleteHiddenField();
    });

    ////// control panel 
    $(".c-small").hover(
      function(){
        $(this).addClass("hover-small");
      },
      function(){
        $(this).removeClass("hover-small");
      }
    );


    ////// star
    $("[id*='star-']").hover(
      function(){
        let starNumber = $(this).attr("id").split('-').pop();
        $.highlightStars(Number(starNumber));
      },
      function (){
        let starNumber = $("#star-value").val();
        $.highlightStars(Number(starNumber));
      }
    );

    $("[id*='star-']").click(function(){
      let starNumber = $(this).attr("id").split('-').pop();
      $('#star-value').val(starNumber);
      changeTangoData({star: starNumber});
      $.highlightStars(Number(starNumber));
      $('#flash-message').html('<span class="alert alert-warning">★を ' + starNumber  + ' に設定しました</span>').hide().fadeIn(300);
      $(function(){
        setTimeout("$('.alert.alert-warning').fadeOut('slow')", 500);
      });
    });

    ////// tango panel 
    learnHtml.click(function(){
      changeTangoStatus();
      resetTimer();
    });
    wrongBtnHtml.click(function(){
      changeTangoData({wrong_num: true, trial_num: true});
      changeTangoStatus();
      resetTimer();
      $('#flash-message').html('<span class="alert alert-danger">ミス</span>').hide().fadeIn(100);
      $(function(){
      setTimeout("$('.alert.alert-danger').fadeOut('slow')", 300);
      });
    });
    correctBtnHtml.click(function(){
      changeTangoData({trial_num: true});
      changeTangoStatus();
      resetTimer();
      $('#flash-message').html('<span class="alert alert-success">正解</span>').hide().fadeIn(100);
      $(function(){
      setTimeout("$('.alert.alert-success').fadeOut('slow')", 300);
      });
    });

    /// modal
    /// modal hint
    hintBtnHtml.click(function(){
      $('#hint-window').fadeIn(200);
    });
    $('#hint-window .modal-close').on('click',function(){
      $('.modal').fadeOut(200);
    });

    //// setTango control
    $("[class*='to-1']").click(function(){
       changeTangoNumber(-1);
       setTango();
    });
    $("[class*='to-10']").click(function(){
       changeTangoNumber(-9);
       setTango();
    });
    $("[class*='to+1']").click(function(){
       changeTangoNumber(1);
       setTango();
    });
    $("[class*='to+10']").click(function(){
       changeTangoNumber(9);
       setTango();
    });
  };

  function resetDeleteHiddenField(){
      let tmp = ""
      $('input:checked').each(function(){
        if( $(this).attr("id") === undefined){ return true; };
        let value = $(this).attr("id").split("-").pop();
        let id = $(this).attr("id").split("-").pop();
        tmp += '<input type="hidden" name="tangos[]" value=' + value + '>';
      });
      $("[name*='tangos']").remove();
      tmp = jQuery(jQuery.parseHTML(tmp));
      deleteBtnHtml.append(tmp);
  };

  function changeTangoNumber(num){
        if(tangoNumber + num >= tangoData.length -2){
          tangoNumber = 0;
         }else if(tangoNumber + num < 0){
          tangoNumber = tangoData.length - 3;
         }else{
           tangoNumber += num;
         };
  };

  function getTangoData(){
    $.ajax({
      url: '/tango_data/0?tango_id=' + tangoArray[tangoNumber].tangoId,
      type: "get",
      dataType: "script",
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token',$('meta[name="csrf-token"]').attr('content'));
      },
    });
  };

  function changeTangoData(tangoDataParams){
    let wordnoteId = Number($('[id*="config-no-"]').attr("id").split("-").pop());
    $.ajax({
      url: '/tango_data/0?tango_id=' + tangoArray[tangoNumber].tangoId,
      type: "patch",
      data: tangoDataParams,
      dataType: "script",
      beforeSend: function(xhr){
        xhr.setRequestHeader('X-CSRF-Token',$('meta[name="csrf-token"]').attr('content'));
      },
    });
  };

  function htmlEscape(str) {
    if (!str) return;
    return str.replace(/[<>&"'`]/g, function(match) {
      const escape = {
        '<': '&lt;',
        '>': '&gt;',
        '&': '&amp;',
        '"': '&quot;',
        "'": '&#39;',
        '`': '&#x60;'
      };
      return escape[match];
    });
  }
  ///// キーボード操作
  $(document).keyup(function(event){
    if (event.keyCode === 39){
      changeTangoStatus();
      resetTimer();
    }
    if (event.keyCode === 37){
      changeTangoNumber(-1);
      setTango();
      resetTimer();
    }
  });
});
