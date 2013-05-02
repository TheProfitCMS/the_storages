module ActAsAttachedFile
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :storage, polymorphic: true
    acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]

    alias_method :need_thumb?, :is_image?

    before_validation :generate_file_name

    after_create   :recalculate_storage_counters
    after_update   :recalculate_storage_counters
    before_destroy :recalculate_storage_counters

    has_attached_file :attachment,
                      styles: {
                        normal: '600x400#',
                        std:    '270x180#',
                        small:  '100x100#',
                        mini:   '50x50#',
                        micro:  '25x25#'
                      },
                      convert_options: { :all => "-strip" },
                      default_url: "/uploads/default/:style/missing.jpg",
                      url:         "/uploads/storages/:storage_type/:storage_id/:attachment_id/:style/:filename"
                      

    validates_attachment_size :attachment,
      in: 10.bytes..5.megabytes,
      message: I18n.translate('the_storages.validation.attachment_file_size')

    validates :attachment_file_name,
      uniqueness: {
        scope: [:user_id, :storage_type, :storage_id],
        message: I18n.translate('the_storages.validation.uniq_attachment_file_name')
      }
  end

  def file_extension
    ext = File.extname(attachment_file_name).downcase
    ext.slice!(0)
    @extension ||= ext
  end

  def file_name
    File.basename attachment_file_name.downcase, file_extension
  end

  def is_image?
    %w[jpg jpeg pjpeg png gif bmp].include? file_extension
  end

  def recalculate_storage_counters
    storage.recalculate_storage_counters
  end

  def generate_file_name
    fname = Russian::translit(file_name).gsub('_','-').parameterize
    self.attachment.instance_write :file_name, "#{fname}.#{file_extension}"
  end
end
