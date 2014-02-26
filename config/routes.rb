Rails.application.routes.draw do
  resources :attached_files do
    collection do
      post  :rebuild
    end

    member do
      patch :watermark_switch
    end
  end
end