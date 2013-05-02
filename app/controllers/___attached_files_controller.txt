class AttachedFilesController < ApplicationController
  before_filter :find_storage,       except: [:destroy]
  before_filter :find_uploaded_file, only:   [:destroy]

  # restricted area

  def create
    if params[:files]
      uploaded_files        = []
      uploaded_files_errors = []

      params[:files].each do |file|
        uploaded_file      = @storage.uploaded_files.new
        uploaded_file.file = file

        uploaded_file.init(:user => @user, :creator => current_user)
        saved = uploaded_file.save

        uploaded_files.push uploaded_file.file_file_name      if     saved
        uploaded_files_errors.push uploaded_file.errors.first unless saved
      end

      if uploaded_files_errors.size > 0
        flash[:error] = 'Ошибки: ' + uploaded_files_errors.join(', ')
      end

      if uploaded_files.size > 0
        flash[:notice] = t('uploaded_files.uploaded_files_list') + uploaded_files.join(', ')
      else
        flash[:notice] = 'Не удалось загрузить ни один файл'
      end
    else
      flash[:error] = t('uploaded_files.have_no_files')
    end

    redirect_to [request.referer, :files].join('#')
  end

  def destroy
    @storage= @uploaded_file.storage
    storage_class   = @storage.class.to_s.downcase.singularize # recipe
    storage_class   = storage_class == 'articles' ? 'news' : storage_class
    @uploaded_file.destroy
    flash[:notice] = t('uploaded_files.deleted')
    redirect_to request.referer || '/'
    #: @uploaded_file.to_deleted
    # redirect_to eval("edit_#{storage_class}_url(@storage, :subdomain=>@storage.user.subdomain)")
  end

  protected

  def find_storage
    # storage_id =    params.delete :storage_id
    # storage_class = params.delete :storage_type
  
    # # 'Recipe'.pluralize.downcase => recipes
    # storages = storage_class.pluralize.downcase
    
    # # @user.recipes.where(:id=>1)
    # @storage = @user.send(storages).where(:id=>storage_id.to_i).first
    # @storage = @user.send(storages).where(:zip=>storage_id).first           unless @storage
    # @storage = @user.send(storages).where(:friendly_url=>storage_id).first  unless @storage

    # unless @storage
    #   flash[:error] = t('uploaded_files.storage_not_found')
    #   redirect_to root_url(:subdomain=>@user.subdomain) and return
    # end    
  end

  def find_uploaded_file
    # @uploaded_file  = @user.uploaded_files.find_by_zip(params[:id])
    # access_denied and return unless @uploaded_file
    # @audited_object = @uploaded_file
    # @object_for_role_system = @uploaded_file
  end

end
