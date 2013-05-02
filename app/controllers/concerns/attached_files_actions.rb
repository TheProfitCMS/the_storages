module AttachedFilesActions
  def create
    if params[:files]
      attached_files_msg        = []
      attached_files_errors_msg = []

      params[:files].each do |file|
        attached_file = @storage.attached_files.new
        attached_file.attachment = file
        
        saved = attached_file.save

        attached_files_msg.push        attached_file.attachment_file_name  if  saved
        attached_files_errors_msg.push attached_file.errors.first          if !saved
      end

      
      flash[:notice] = attached_files_msg.join(', ')
      flash[:error]  = attached_files_errors_msg.join(', ')

      redirect_to [request.referer, :files].join('#')
    end

    # if params[:files]
    #   attached_files        = []
    #   attached_files_errors = []

    #   params[:files].each do |file|
    #     attached_file      = @storage.attached_files.new
    #     attached_file.file = file

    #     attached_file.init(:user => @user, :creator => current_user)
    #     saved = attached_file.save

    #     attached_files.push attached_file.file_file_name      if     saved
    #     attached_files_errors.push attached_file.errors.first unless saved
    #   end

    #   if attached_files_errors.size > 0
    #     flash[:error] = 'Ошибки: ' + attached_files_errors.join(', ')
    #   end

    #   if attached_files.size > 0
    #     flash[:notice] = t('attached_files.attached_files_list') + attached_files.join(', ')
    #   else
    #     flash[:notice] = 'Не удалось загрузить ни один файл'
    #   end
    # else
    #   flash[:error] = t('attached_files.have_no_files')
    # end

    # redirect_to [request.referer, :files].join('#')
  end

end