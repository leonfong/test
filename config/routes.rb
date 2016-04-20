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
  #resources :work_flow
  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/how_to_use', to: 'static_pages#how', via: 'get'
  match '/search', to: 'boms#search_keyword', via: 'get'
  match '/down_excel', to: 'boms#down_excel', via: 'get'
  match '/show_excel', to: 'boms#show_excel', via: 'get'
  match '/work_flow', to: 'work_flow#index', via: 'post'  
  match '/work_flow', to: 'work_flow#index', via: 'get'  
  match '/up_work', to: 'work_flow#up_work', via: 'post'
  match '/edit_work', to: 'work_flow#edit_work', via: 'post'
  match '/edit_work', to: 'work_flow#edit_work', via: 'get'
  match '/up_warehouse', to: 'work_flow#up_warehouse', via: 'post'
  match '/order_state', to: 'work_flow#order_state', via: 'post'
  match '/feedback', to: 'work_flow#show', via: 'get'
  match '/add_feed', to: 'work_flow#add_feed', via: 'post'
  match '/indexup', to: 'work_flow#indexup', via: 'get' 
  match '/up_enddate', to: 'work_flow#up_enddate', via: 'post' 

  match '/timesheet', to: 'timesheet#index', via: 'post'  
  match '/timesheet', to: 'timesheet#index', via: 'get' 
  match '/up_timesheet', to: 'timesheet#up_timesheet', via: 'post'  
  match '/down_timesheet', to: 'timesheet#down_excel', via: 'post'

  match '/mpn_info', to: 'mpn_info#index', via: 'get' 
  match '/up_mpn', to: 'mpn_info#up_mpn', via: 'post' 
  match '/down_mpn_excel', to: 'mpn_info#down_excel', via: 'get'

  root to: 'boms#root'
  #root to: "boms#index"
  match '/new_bom', to: 'boms#upbom',via: 'post'
  match '/new_bom', to: 'boms#upbom',via: 'get'
  match '/boms/choose', to: 'boms#choose',via: 'get'
  #match '/boms', to: 'boms#index',via: 'get'
  match '/boms/search_api', to: 'boms#search_api',via: 'post'
  match '/bom_item/edit', to: 'bom_item#edit', via: 'post'
  match '/boms/mpn', to: 'boms#mpn#', via: 'get'
  match '/mpn_item', to: 'boms#mpn_item', via: 'get'
  match '/des_item', to: 'boms#des_item', via: 'get'
  match '/search_part', to: 'boms#search_part',via: 'post'
  match '/viewbom', to: 'boms#viewbom',via: 'get'
  match '/vieworder', to: 'boms#vieworder',via: 'get'
  match '/bomlist', to: 'boms#bomlist',via: 'get'
  match '/up_order_info', to: 'boms#up_order_info',via: 'post'
  match '/up_order_info', to: 'boms#up_order_info',via: 'get'
  match '/up_pcb_info', to: 'boms#up_pcb_info',via: 'get'
  match '/up_pcb_info', to: 'boms#up_pcb_info',via: 'post'
  match '/create_order', to: 'boms#create_order',via: 'post'
  match '/orderlist', to: 'boms#orderlist',via: 'post'
  match '/orderlist', to: 'boms#orderlist',via: 'get'
  match '/order_review_list', to: 'boms#order_review_list',via: 'get'
  match '/order_review', to: 'boms#order_review',via: 'get'
  match '/review_pass', to: 'boms#review_pass',via: 'post'
  match '/order_dc_list', to: 'boms#order_dc_list',via: 'get'
  match '/order_dc', to: 'boms#order_dc',via: 'get'
  match '/dc_pass', to: 'boms#dc_pass',via: 'post' 
  match '/pcb_dc_change', to: 'boms#pcb_dc_change',via: 'post' 
  match '/pcb_r_change', to: 'boms#pcb_r_change',via: 'post' 
  match '/select_column', to: 'boms#select_column',via: 'get' 
  match '/user_profile', to: 'boms#user_profile',via: 'get' 
  match '/up_user_profile', to: 'boms#up_user_profile',via: 'post' 
  match '/edit_billing', to: 'boms#edit_billing',via: 'post' 
  match '/edit_shipping', to: 'boms#edit_shipping',via: 'post'
  match '/del_billing', to: 'boms#del_billing',via: 'get' 
  match '/del_shipping', to: 'boms#del_shipping',via: 'get' 
  match '/edit_shipping_js', to: 'boms#edit_shipping_js',via: 'post'
  match '/update_bom', to: 'boms#update_bom',via: 'post'
  match '/get_bom', to: 'boms#get_bom',via: 'get'
  match '/del_bom', to: 'boms#del_bom',via: 'get'
  match '/add_bom', to: 'boms#add_bom',via: 'post'

  resources :boms, only: [:index,:show, :new, :create, :destroy, :mark, :mpn]
  #resources :boms
  resources :bom_item
  #match '/search', to: 'boms#search', via: 'get'

  #match 'choose'=> 'boms#choose'
  match '/mark', to: 'boms#mark', via: 'post'
  match '/s_mpn', to: 'boms#s_mpn', via: 'post'
  match '/bom_item/add', to: 'bom_item#add', via: 'post'
  match '/root', to: 'boms#root', via: 'post'
  match '/upload', to: 'boms#upload', via: 'get'
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
