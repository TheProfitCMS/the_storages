module TheStoragesHelper
  def file_type_icon file
    case
      when file.is_doc? then
        image_tag('doctype/100x100/doc.jpg', :alt=>t('file_types.text_document'), :title=>t('file_types.text_document'))
      when file.is_txt? then
        image_tag('doctype/100x100/txt.jpg', :alt=>t('file_types.text_file'), :title=>t('file_types.text_file'))
      when file.is_ppt? then
        image_tag('doctype/100x100/ppt.jpg', :alt=>t('file_types.presentation'), :title=>t('file_types.presentation'))
      when file.is_xls? then
        image_tag('doctype/100x100/xls.jpg', :alt=>t('file_types.e_table'), :title=>t('file_types.e_table'))
      when file.is_pdf? then
        image_tag('doctype/100x100/pdf.jpg', :alt=>t('file_types.pdf'), :title=>t('file_types.pdf'))
      when file.is_psd? then
        image_tag('doctype/100x100/psd.jpg', :alt=>t('file_types.psd'), :title=>t('file_types.psd'))
      when file.is_media? then
        image_tag('doctype/100x100/media.jpg', :alt=>t('file_types.media'), :title=>t('file_types.media'))
      when file.is_arch? then
        image_tag('doctype/100x100/zip.jpg', :alt=>t('file_types.archive'), :title=>t('file_types.archive'))
      else
        image_tag 'doctype/100x100/default.jpg', :alt=>t('file_types.file'), :title=>t('file_types.file')
    end
  end#fn

end
