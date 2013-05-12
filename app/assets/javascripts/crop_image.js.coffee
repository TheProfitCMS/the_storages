@showCoords = (coords, img) ->
  $('#x').html  coords.x
  $('#y').html  coords.y

  $('#w').html  coords.w
  $('#h').html  coords.h

  $('#img_w').html img.width()

$ ->
  img_selector = '#main_preview_crop'
  img = $ img_selector
  
  img.load ->
    window.preview_crop = $.Jcrop img_selector,
      aspectRatio: 1
      onChange: (coords) ->
        showCoords(coords, img)
      onSelect: (coords) ->
        showCoords(coords, img)

  $('#crop_image_on_server').click ->
    params = {
      _method: 'patch'
      x: $('#x').html()
      y: $('#y').html()
      w: $('#w').html()
      h: $('#h').html()
      img_w: $('#img_w').html()
      image_id: $('#image_id').html()
      no_cache: (new Date).getTime()
    }
  
    $.ajax
      type: 'POST'
      data: params
      url: "/image_processor/crop_image"
      success: (result,status,request) ->
        $('#crop_result').html "<img src='#{result}'>"
      error: ->
        log 'error'