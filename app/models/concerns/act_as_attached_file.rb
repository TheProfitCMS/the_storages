module ActAsAttachedFile
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :storage, polymorphic: true
    acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]

    before_validation :generate_file_name, on: :create

    # IMAGE PROCESSING HOOKS
    def set_processing_flag; self.processing = :processing; end
    before_create :set_processing_flag,      if: ->(attachment){ attachment.is_image? }
    after_create  :delayed_image_processing, if: ->(attachment){ attachment.is_image? }
    #~ IMAGE PROCESSING HOOKS

    has_attached_file :attachment,
                      default_url: "/uploads/default/:style/missing.jpg",
                      url:         "/uploads/storages/:storage_type/:storage_id/:filename"

    validates_attachment_size :attachment,
      in: 10.bytes..5.megabytes,
      message: I18n.translate('the_storages.validation.attachment_file_size')

    validates :attachment_file_name,
      uniqueness: {
        scope: [:user_id, :storage_type, :storage_id],
        message: I18n.translate('the_storages.validation.uniq_attachment_file_name')
      }
  end

  # ACCELERATORS
  def path style = nil
    attachment.path(style)
  end

  def url style = nil
    attachment.url(style).split('?').first
  end

  # FILE STYLE HELPERS (for image files processing)
  def styled_file_name str, style
    style = style.nil? ? '' : "_#{style}"
    name  = attachment_file_name.split('.')
    ext   = name.pop
    str.gsub attachment_file_name, "#{name.join('.')}#{style}.#{ext}"
  end

  def styled_path style = nil
    styled_file_name(attachment.path, style)
  end

  def styled_url style = nil
    styled_file_name(attachment.url, style)
  end

  # HELPERS
  def file_extension
    ext = File.extname(attachment_file_name).downcase
    ext.slice!(0)
    @extension ||= ext
  end

  def content_type
    attachment.content_type
  end

  def mb_size
    sprintf("%.3f", attachment.size.to_f/1.megabyte.to_f) + " MB"
  end

  # BASE HELPERS
  def file_name
    File.basename attachment_file_name.downcase, file_extension
  end

  def is_image?
    %w[jpg jpeg pjpeg png gif bmp].include? file_extension
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
    Delayed::Job.enqueue job, queue: :image_processing, run_at: Proc.new { 10.seconds.from_now }
  end

  # IMAGE ROTATION
  def image_rotate angle
    src      = path
    original = styled_path(:original)
    preview  = styled_path(:preview)

    # original
    image = MiniMagick::Image.open src
    image.rotate angle
    image.write src
    image.write original

    # preview
    image = MiniMagick::Image.open original
    image.resize "100x100!"
    image.write preview
  end

  def rotate_left
    image_rotate "-90"
  end

  def rotate_right
    image_rotate "90"
  end
end

# alias_method :need_thumb?, :is_image?
# after_create   :recalculate_storage_counters
# after_update   :recalculate_storage_counters
# before_destroy :recalculate_storage_counters
# before_save    { @is_new_record = id.nil?; p("===========================>>>>>", @is_new_record) }
# before_save    :processing_state_for_images
# after_commit   :build_image_variants, if: -> { p("====0000000000000000000========>>>>>", @is_new_record); @is_new_record }