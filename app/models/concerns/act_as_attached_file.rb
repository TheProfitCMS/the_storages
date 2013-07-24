# encoding: UTF-8
module ActAsAttachedFile
  extend ActiveSupport::Concern
  include AttachmentProcessing
  include StorageImageProcessing

  included do
    IMAGE_EXTS = %w[jpg jpeg pjpeg png x-png gif bmp]
    IMAGE_CONTENT_TYPES = IMAGE_EXTS.map{ |e| "image/#{e}" }

    belongs_to :user
    belongs_to :storage, polymorphic: true
    acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]
    include TheSortableTree::Scopes
    
    before_validation :generate_file_name, on: :create
    # after_create   :recalculate_storage_counters
    # after_update   :recalculate_storage_counters
    # before_destroy :recalculate_storage_counters

    scope :images, ->{ where(attachment_content_type: IMAGE_CONTENT_TYPES)  }
  end

  def file_css_class
    'f_' + TheStorages.file_ext(attachment_file_name)
  end

  # HELPERS
  def title
    attachment_file_name
  end

  def file_name
    TheStorages.file_name(attachment_file_name)
  end

  def content_type
    attachment_content_type
  end

  def mb_size
    sprintf("%.3f", attachment_file_size.to_f/1.megabyte.to_f) + " MB"
  end

  def path style = nil
    attachment.path(style)
  end

  def url style = nil, opts = {}
    url = attachment.url(style, opts)
    return url unless opts[:nocache]
    rnd = (rand*1000000).to_i.to_s
    url =~ /\?/ ? (url + rnd) : (url + '?' + rnd)
  end

  # BASE HELPERS
  def is_image?
    IMAGE_EXTS.include? TheStorages.file_ext(attachment_file_name)
  end

  def generate_file_name
    file_name  = attachment.instance_read(:file_name)
    file_name  = TheStorages.slugged_file_name(file_name)
    attachment.instance_write :file_name, file_name
  end

  # CALLBACKS
  def recalculate_storage_counters
    storage.recalculate_storage_counters
  end
end