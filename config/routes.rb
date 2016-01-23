Rails.application.routes.draw do
  
  get '/change_locale/:locale', to: 'settings#change_locale', as: :change_locale
  devise_for :users
  devise_for :admins, :skip => [:sessions]
  as :admin do
    get 'signin' => 'devise/sessions#new', :as => :new_admin_session
    post 'signin' => 'devise/sessions#create', :as => :admin_session
    delete 'signout' => 'devise/sessions#destroy', :as => :destroy_admin_session
  end
  #mount RailsAdmin::Engine => '/moko', as: 'rails_admin'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/how_to_use', to: 'static_pages#how', via: 'get'
  match '/search', to: 'boms#search_keyword', via: 'get'
  match '/down_excel', to: 'boms#down_excel', via: 'get'
  
  root to: 'boms#upload'
  #root to: "boms#index"
  match '/boms/choose', to: 'boms#choose',via: 'get'
  #match '/boms', to: 'boms#index',via: 'get'
  match '/boms/search_api', to: 'boms#search_api',via: 'post'
  match '/bom_item/edit', to: 'bom_item#edit', via: 'post'
  match '/boms/mpn', to: 'boms#mpn#', via: 'get'
  match '/boms/mpn_item', to: 'boms#mpn_item', via: 'get'
  match '/boms/des_item', to: 'boms#des_item', via: 'get'

  resources :boms, only: [:index,:show, :new, :create, :destroy, :mark, :mpn]
  #resources :boms
  resources :bom_item
  match '/search', to: 'boms#search', via: 'get'
  
  #match 'choose'=> 'boms#choose'
  match '/mark', to: 'boms#mark', via: 'post'
  match '/s_mpn', to: 'boms#s_mpn', via: 'post'
  match '/bom_item/add', to: 'bom_item#add', via: 'post'
  #
  match '/bom_item/select_with_ajax', to: 'bom_item#select_with_ajax', via: 'post'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
