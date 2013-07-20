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
  end

  def watermark_switch
    attachment = AttachedFile.find(params[:id])
    attachment.toggle!(:watermark)
    attachment.refresh_base_image
    render nothing: true
  end

  def destroy
    attachment = AttachedFile.find(params[:id])
    attachment.destroy_processed_files
    attachment.destroy
    redirect_to [request.referer, :files].join('#')
  end
end