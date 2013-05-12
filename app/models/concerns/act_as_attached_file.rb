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

  def url style = nil
    attachment.url(style).split('?').first
  end

  # FILE STYLE HELPERS (for image files processing)
  def styled_file_name str, style, nocache = false
    style = style.nil? ? '' : "_#{style}"
    name  = attachment_file_name.split('.')
    ext   = name.pop
    fn = str.gsub attachment_file_name, "#{name.join('.')}#{style}.#{ext}"
    return fn unless nocache
    fn + (rand*1000000).to_i.to_s
  end

  def styled_path style = nil, nocache = false
    styled_file_name(attachment.path, style, nocache)
  end

  def styled_url style = nil, nocache = false
    styled_file_name(attachment.url, style, nocache)
  end

  # BASE HELPERS
  def is_image?
    IMAGE_EXTS.include? file_extension
  end

  def generate_file_name
    fname = Russian::translit(file_name).gsub('_','-').parameterize
    self.attachment.instance_write :file_name, "#{fname}.#{file_extension}"
  end

  def landscape? image
    image[:width] > image[:height]
  end

  def portrait? image
    image[:width] < image[:height]
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

  def build_base_images
    # file path
    src      = path
    original = styled_path(:original)
    preview  = styled_path(:preview)

    # original
    image = MiniMagick::Image.open src
    image.auto_orient
    landscape?(image) ? image.resize('800x') : image.resize('x800') if image[:width] > 800
    image.strip
    image.write original

    # preview
    image = MiniMagick::Image.open original
    image.resize "100x100!"
    image.write preview

    # delete source
    image = MiniMagick::Image.open original
    image.write src

    # set process state
    src_size = File.size?(src)
    update(processing: :finished, attachment_file_size: src_size)
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

  # IMAGE CROP
  def crop_image name = :cropped_image, x_shift = 0, y_shift = 0, w = 100, h = 100, img_w = nil
    src      = path
    original = styled_path :original
    cropped  = styled_path name

    image = MiniMagick::Image.open original
    
    img_w ||= image[:width]
    scale   = image[:width].to_f/img_w.to_f

    w = (w.to_f * scale).to_i
    h = (h.to_f * scale).to_i

    x_shift = (x_shift.to_f * scale).to_i
    y_shift = (y_shift.to_f * scale).to_i

    image.crop "#{w}x#{h}+#{x_shift}+#{y_shift}"
    image.write cropped
  end
end