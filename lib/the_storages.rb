require 'the_storages/config'
require 'the_storages/version'

module TheStorages
  class Engine < Rails::Engine; end

  def self.has_watermark?
    !self.config.watermark_text.blank?
  end
end