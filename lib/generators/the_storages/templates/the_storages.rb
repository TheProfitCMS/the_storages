# TheStorages.config.param_name => value

TheStorages.configure do |config|
  config.watermark_text      = 'https://github.com/the-teacher'
  config.convert_path        = '/usr/bin/convert'               # BSD: /usr/local/bin/
  config.watermark_font_path = nil                              # "#{Rails.root.to_s}/vendor/fonts/georgia_italic.ttf"
end