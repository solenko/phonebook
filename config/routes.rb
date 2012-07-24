Phonebook::Application.routes.draw do
  root :to => 'phones#index'
  resources :phones, :except => :show do
    post :import, :on => :collection
  end
  devise_for :users
end
