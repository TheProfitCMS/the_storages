class AttachedFile < ActiveRecord::Base  
  belongs_to :user
  belongs_to :storage, :polymorphic: true
  acts_as_nested_set scope: [:user_id, :storage_id, :storage_type]

  has_attached_file :attachment,
                    styles: {
                      normal: '600x400#',
                      std:    '270x180#',
                      small:  '100x100#',
                      mini:   '50x50#',
                      micro:  '25x25#'
                    },
                    convert_options: { :all => "-strip" },
                    url:         "/uploads/:attachment/:style/:filename",
                    default_url: "/uploads/default/:style/missing.jpg"

  validates_attachment_size :attachment, in: 10.bytes..5.megabytes, message: I18n.translate('the_storages.validation.attachment_file_size')
  validates :attachment_file_name, uniqueness: { message: I18n.translate('the_storages.validation.uniq_attachment_file_name'), scope: [:user_id, :storage_type, :storage_id] }

  # # FILTERS
  # before_validation :generate_file_name
  # before_destroy    :update_storage
  # after_create      :update_storage
  # after_update      :update_storage

  # def update_storage
  #   self.storage.save
  # end

  # def generate_file_name
  #   #file_name=  self.title
  #   #self.title= self.file_title_filter(self.title)
  #   extension=  File.extname(self.base_file_name).downcase
  #   file_name=  File.basename(self.base_file_name, extension)
  #   file_name=  self.file_name_filter(file_name)
  #   self.file.instance_write(:file_name, "#{file_name}#{extension}")
  # end

  # # functions for FILTERS
  # # Russian.translit(' _ Иван _  Иванов  ^@#$&№%*«»!?.,:;{}()<>_+|/~ Test     ----').text_symbols2dash.underscore2dash.spaces2dash.strip_dashes.downcase
  # # => "ivan-ivanov-test"
  # def file_name_filter file_name
  #   return Russian.translit(file_name).text_symbols2dash.remove_quotes.underscore2dash.spaces2dash.strip_dashes.downcase
  # end

  # # '«Олимпиада для школьников» и новый год + снегурочка & Dead Moро$O;ff!!!'.text_symbols2dash.spaces2dash.strip_dashes.dashes2space
  # # => "Олимпиада для школьников и новый год снегурочка Dead Moро O ff"
  # def file_title_filter title
  #   return title.text_symbols2dash.remove_quotes.spaces2dash.strip_dashes.dashes2space
  # end

  # # HELPERS
  # def full_filepath
  #   Project::ADDRESS + self.file.url.split('?').first
  # end

  # def to_textile_link
  #   "\"#{self.file_file_name}\":#{self.full_filepath}"
  # end

  # # FILE INFO METHODS
  # def base_file_name
  #   self.file_file_name.to_s
  # end

  # def base_file_type
  #   self.file.content_type
  # end

  # FILE TYPES METHODS
  # def is_image?
  #   ['.gif','.jpeg','.jpg','.pjpeg','.png','.bmp'].include?(File.extname(base_file_name))
  # end
  
  # def need_thumb?
  #   is_image?
  # end
  
  # def is_doc?
  #   ['.doc', '.docx'].include?(File.extname(base_file_name))
  # end
  
  # def is_txt?
  #   ['text/plain'].include?(base_file_type)
  # end
  
  # def is_ppt?
  #   ['application/vnd.ms-powerpoint', 'application/x-ppt'].include?(base_file_type)
  # end
  
  # def is_xls?
  #   ['application/vnd.ms-excel'].include?(base_file_type)
  # end
  
  # def is_pdf?
  #   ['application/pdf'].include?(base_file_type)
  # end  
  
  # def is_psd?
  #   ['.psd'].include?(File.extname(base_file_name))
  # end
  
  # def is_media?
  #   ['video/x-msvideo','audio/wav','application/x-wmf','video/mpeg','audio/mpeg','audio/mp3'].include?(base_file_type)
  # end
  
  # def is_arch?
  #   ['.zip','.rar','.gz','.tar'].include?(File.extname(base_file_name))
  # end

end