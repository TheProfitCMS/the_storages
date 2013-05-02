# Paperclip.options[:command_path] = '/usr/local/bin/'

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

Paperclip::Attachment.class_eval do
  def post_process_styles_with_validation
    p '-&'*40
    p "NEED TUMB?" + instance.need_thumb?.to_s
    p "IMG?" + instance.is_image?.to_s
    p "EXT?" + instance.file_extension
    p '-&'*40

    return unless instance.need_thumb? rescue nil
    post_process_styles_without_validation
  end

  alias_method_chain :post_process_styles, :validation
end