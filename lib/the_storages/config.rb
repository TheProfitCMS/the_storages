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

    config_accessor :convert_path,

                    :watermark_text,
                    :watermark_flag,
                    :watermarks_path,
                    :watermark_font_path,

                    :original_larger_side,
                    :base_larger_side,

                    :file_min_size,
                    :file_max_size,

                    :default_url,
                    :attachment_path,
                    :attachment_url
  end

  configure do |config|
    config.convert_path = '/usr/bin/convert'

    config.watermark_flag      = true
    config.watermark_font_path = nil
    config.watermark_text      = 'https://github.com/the-teacher'
    config.watermarks_path     = "#{ Rails.root.to_s }/public/uploads/watermarks"

    config.file_min_size = 10.bytes
    config.file_max_size = 30.megabytes

    config.default_url     = ":rails_root/public/uploads/attachments_default/:style-missing.jpg"
    config.attachment_path = ":rails_root/public/uploads/storages/:storage_type/:storage_id/:style/:filename"
    config.attachment_url  = "/uploads/storages/:storage_type/:storage_id/:style/:filename"

    config.original_larger_side = 1024
    config.base_larger_side     = 800
  end
end
