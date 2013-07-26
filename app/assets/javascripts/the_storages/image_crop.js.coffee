class @ImageCrop
  @setCoords = (coords, img) ->
    $('#x').val  coords.x
    $('#y').val  coords.y
    $('#w').val  coords.w
    $('#h').val  coords.h
    $('#img_w').val img.width()

  @hideCropWindow = ->
    croppped_preview = $('#cropped_main_image_preview')
    preview_holder   = croppped_preview.parent()
    $('#main_image_cropping_save').hide()
    $('#x, #y, #w, #h, #img_w').val('')
    preview_holder.hide()

  @showPreview = (coords, img) ->
    if parseInt(coords.w) > 0
      croppped_preview = $('#cropped_main_image_preview')
      cropped_save     = $('#main_image_cropping_save')
      preview_holder   = croppped_preview.parent()

      rx = preview_holder.width()  / coords.w
      ry = preview_holder.height() / coords.h

      iw = $(img).width()
      ih = $(img).height()

      croppped_preview.css
        width:       Math.round(rx * iw) + 'px'
        height:      Math.round(ry * ih) + 'px'
        marginLeft:  '-' + Math.round(rx * coords.x) + 'px'
        marginTop:   '-' + Math.round(ry * coords.y) + 'px'

      cropped_save.show()
      preview_holder.show()

  @init = ->
    rlink  = $ '.jcrop_run'
    slink  = $ '.jcrop_stop'
    holder = rlink.parents('.image_toolbar')

    $('.cropped_preview_holder').on 'click', '#main_image_cropping_save', (e) ->
      $('#main_image_cropping').submit()
      false

    rlink.click ->
      $('.base_view', holder).hide()
      $('.crop_view', holder).show()
      false

    slink.click ->
      $('.base_view', holder).show()
      $('.crop_view', holder).hide()
      false

    img_selector = '#main_image_jcrop'
    img = $ img_selector

    img.load ->
      window.main_image_jcrop = $.Jcrop img_selector,
        aspectRatio: 8/6
        onChange: (coords) ->
          ImageCrop.setCoords(coords, img)
          ImageCrop.showPreview(coords, img)
        onSelect: (coords) ->
          ImageCrop.showPreview(coords, img)

        onRelease: ->
          ImageCrop.hideCropWindow()