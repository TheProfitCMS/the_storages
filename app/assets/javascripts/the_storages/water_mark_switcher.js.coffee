class @WaterMarkSwitcher
  @init = ->
    $('.watermark_switcher').on 'click', '.wm_on, .wm_off', ->
      link = $ @
      id   = link.parents('li').data('node-id')

      if link.toggleClass('wm_on wm_off').hasClass('wm_on')
        link.html 'Вкл.'
      else
        link.html 'Выкл.'

      $.ajax
        type: 'POST'
        url: '/attached_files/watermark_switch'
        data:
          id: id
          _method: 'patch'
