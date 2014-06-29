Rails.application.routes.draw do
  resources :attached_files do
    collection do
      post :rebuild
    end
  end
end
