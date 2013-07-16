# encoding: UTF-8
module ActAsAttachedFile
  extend ActiveSupport::Concern

  included do
    IMAGE_EXTS = %w[jpg jpeg pjpeg png gif bmp]
    IMAGE_CONTENT_TYPES = IMAGE_EXTS.map{ |e| "image/#{e}" }

    belongs_to :user
    belongs_to :storage, polymorphic: true
    acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]
    
    before_validation :generate_file_name, on: :create
    # after_create   :recalculate_storage_counters
    # after_update   :recalculate_storage_counters
    # before_destroy :recalculate_storage_counters

    scope :images, ->{ where(attachment_content_type: IMAGE_CONTENT_TYPES)  }

    # IMAGE PROCESSING HOOKS
    def set_processing_flag; self.processing = :processing; end
    before_create :set_processing_flag,      if: ->(attachment){ attachment.is_image? }
    after_create  :delayed_image_processing, if: ->(attachment){ attachment.is_image? }
    #~ IMAGE PROCESSING HOOKS

    has_attached_file :attachment,
                      default_url: "/uploads/default/:style/missing.jpg",
                      url:         "/uploads/storages/:storage_type/:storage_id/:style-:filename"

    validates_attachment_size :attachment,
      in: 10.bytes..5.megabytes,
      message: I18n.translate('the_storages.validation.attachment_file_size')

    validates :attachment_file_name,
      uniqueness: {
        scope: [:user_id, :storage_type, :storage_id],
        message: I18n.translate('the_storages.validation.uniq_attachment_file_name')
      }
  end

  # HELPERS
  def title
    attachment_file_name
  end

  def file_name
    File.basename attachment_file_name.downcase, file_extension
  end

  def file_extension
    ext = File.extname(attachment_file_name).downcase
    ext.slice!(0)
    @extension ||= ext
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
    IMAGE_EXTS.include? file_extension
  end

  def generate_file_name
    fname = Russian::translit(file_name).gsub('_','-').parameterize
    self.attachment.instance_write :file_name, "#{fname}.#{file_extension}"
  end

  # CALLBACKS
  def recalculate_storage_counters
    storage.recalculate_storage_counters
  end

  # DELAYED JOB
  def delayed_image_processing
    job = DelayedImageProcessor.new(self)
    job.perform
    # Delayed::Job.enqueue job, queue: :image_processing, run_at: Proc.new { 10.seconds.from_now }
  end

  # IMAGE PROCESSING
  include ImageWatermarkProcessing

end