module TheStoragesImageProcessor
  def rotate_left
    attached_file = AttachedFile.where(id: params[:id]).first
    attached_file.rotate_left
    render text: :rotate_left_ok
  end

  def rotate_right
    attached_file = AttachedFile.where(id: params[:id]).first
    attached_file.rotate_right
    render text: :rotate_right_ok
  end

  def crop_image
    x = params
    attached_file = AttachedFile.where(id: x[:image_id]).first
    attached_file.crop_image(:main_preview, x[:x], x[:y], x[:w], x[:h], x[:img_w])
    render text: attached_file.url(:main_preview, nocache: true)
  end
end