module FileSizeHelper
  def self.mb_size(bytes)
    [sprintf("%.3f", bytes.to_f/1.megabyte.to_f), I18n.t('file_size_helper.mb')].join('&nbsp;')
  end

  def mb_size(bytes)
    FileSizeHelper.mb_size(bytes)
  end
end
