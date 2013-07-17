require 'the_storages/config'
require 'the_storages/version'

def require_app_level_initializer
  # require app level initializer if it's exists
  app_initializer = Rails.root.to_s + '/config/initializers/the_storages.rb'
  require(app_initializer) if File.exists?(app_initializer)
end

module TheStorages
  class Engine < Rails::Engine; end

  def self.has_watermark?
    !self.config.watermark_text.blank?
  end
end