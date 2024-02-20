Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :video, only: [:new, :create, :show]
  root 'video#new'
end
