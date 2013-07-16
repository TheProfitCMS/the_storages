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
    config_accessor :watermark_text, :convert_path
  end

  configure do |config|
    config.watermark_text = 'https://github.com/the-teacher'
    config.convert_path   = '/usr/bin/convert'
  end
end