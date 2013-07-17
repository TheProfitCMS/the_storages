module TheStorages
  def self.configure(&block)
    yield @config ||= TheStorages::Configuration.new
  end

  def self.config
    @config
  end

  # Configuration class
  class Configuration
    include ActiveSupport::Configurable

    config_accessor :watermark_text,
                    :convert_path,
                    :watermark_font_path,
                    :original_larger_side,
                    :base_larger_side,
                    :watermarks_path
  end

  configure do |config|
    config.watermark_text = 'https://github.com/the-teacher'
    config.convert_path   = '/usr/bin/convert'

    config.watermark_font_path = nil
    config.watermarks_path     = "#{Rails.root.to_s}/public/uploads/watermarks"

    config.original_larger_side = 1024
    config.base_larger_side     = 800
  end
end