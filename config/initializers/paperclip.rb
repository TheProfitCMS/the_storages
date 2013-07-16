# require app level initializer if it's exists
app_initializer = Rails.root.to_s + '/config/initializers/the_storages.rb'
require(app_initializer) if File.exists?(app_initializer)

Paperclip.options[:command_path] = TheStorages.config.convert_path

module Paperclip
  module Interpolations
    def storage_id attachment, style
      attachment.instance.storage_id
    end

    def storage_type attachment, style
      attachment.instance.storage_type.downcase
    end

    def attachment_id attachment, style
      attachment.instance.id
    end
  end
end

# Paperclip.options[:command_path] = '/usr/local/bin/'

# Paperclip::Attachment.class_eval do
#   def post_process_styles_with_validation
#     return unless instance.need_thumb? rescue nil
#     post_process_styles_without_validation
#   end

#   alias_method_chain :post_process_styles, :validation
# end