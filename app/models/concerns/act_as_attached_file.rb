# encoding: UTF-8
module ActAsAttachedFile
  extend ActiveSupport::Concern
  include AttachmentProcessing
  include StorageImageProcessing

  IMAGE_EXTS = %w[jpg jpeg pjpeg png x-png gif bmp]
  IMAGE_CONTENT_TYPES = IMAGE_EXTS.map{ |e| "image/#{e}" }

  included do
    # PAPPERCLIP
    has_attached_file :attachment ,
                      default_url: ":rails_root/public/system/uploads/default/:style-missing.jpg",
                      path:        ":rails_root/public/system/storages/:storage_type/:storage_id/:style/:filename",
                      url:         "/system/storages/:storage_type/:storage_id/:style/:filename"

    validates_attachment_content_type :attachment, :content_type => /\A\w|\S|\s\Z/

    validates_attachment_size :attachment,
      in: 10.bytes..5.megabytes,
      message: I18n.translate('the_storages.validation.attachment_file_size')

    validates :attachment_file_name,
      uniqueness: {
        scope: [:user_id, :storage_type, :storage_id],
        message: I18n.translate('the_storages.validation.uniq_attachment_file_name')
      }
    # ~ PAPPERCLIP

    belongs_to :user
    belongs_to :storage, polymorphic: true
    acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]
    include TheSortableTree::Scopes

    attr_accessor :image_processing
    before_create :set_processing_flags
    after_commit  :delayed_file_processing
    before_validation :generate_file_name, on: :create
    after_create   :recalculate_storage_counters!
    after_destroy  :recalculate_storage_counters!
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
    FileSizeHelper.mb_size(attachment_file_size)
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
  def recalculate_storage_counters!
    storage.recalculate_storage_counters!
  end
end