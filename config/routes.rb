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

  match '/oauth/callback', to: 'oauth#callback', via: 'get'

  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/faq', to: 'static_pages#faq', via: 'get'
  match '/terms', to: 'static_pages#terms', via: 'get'
  match '/return', to: 'static_pages#returns', via: 'get'
  match '/shipping', to: 'static_pages#shipping', via: 'get'
  match '/supplier', to: 'static_pages#supplier', via: 'get'
  match '/payment', to: 'static_pages#payment', via: 'get'
  match '/privacy', to: 'static_pages#privacy', via: 'get'
  match '/technical', to: 'static_pages#technical', via: 'get'
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
  match '/sell_baojia', to: 'work_flow#sell_baojia', via: 'get' 
  match '/sell_baojia', to: 'work_flow#edit_orderinfo', via: 'post'
  match '/sell_view_baojia', to: 'work_flow#sell_view_baojia', via: 'get'
  match '/moko_part_manage', to: 'work_flow#moko_part_manage', via: 'get'
  match '/moko_part_update', to: 'work_flow#moko_part_update', via: 'post'
  match '/sell_pcb_baojia', to: 'work_flow#sell_pcb_baojia', via: 'get'
  match '/add_pcb_customer', to: 'work_flow#add_pcb_customer', via: 'post'
  match '/edit_pcb_customer', to: 'work_flow#edit_pcb_customer', via: 'post'
  match '/pcb_order_list', to: 'work_flow#pcb_order_list', via: 'get'
  match '/new_pcb_order', to: 'work_flow#new_pcb_order', via: 'post'
  match '/add_pcb_order', to: 'work_flow#add_pcb_order', via: 'post'
  match '/edit_pcb_order', to: 'work_flow#edit_pcb_order', via: 'post'
  match '/work_flow/select_pcbcustomer_ajax', to: 'work_flow#select_pcbcustomer_ajax', via: 'get'
  match '/update_pcb_price', to: 'work_flow#update_pcb_price', via: 'post'
  match '/release_pcb_to_order', to: 'work_flow#release_pcb_to_order', via: 'post'
  match '/release_pcb_to_quote', to: 'work_flow#release_pcb_to_quote', via: 'get'
  match '/release_pcb_to_quotechk', to: 'work_flow#release_pcb_to_quotechk', via: 'get'
  match '/follow', to: 'work_flow#follow', via: 'get'
  match '/find_c', to: 'work_flow#find_c', via: 'get'
  match '/del_pcb_order', to: 'work_flow#del_pcb_order', via: 'get'
  match '/back_pcb_to_order', to: 'work_flow#back_pcb_to_order', via: 'get'
  match '/del_pcb_follow', to: 'work_flow#del_pcb_follow', via: 'get'


  match '/procurement_new', to: 'procurement#p_create_bom', via: 'get' 
  match '/p_new_bom', to: 'procurement#p_upbom',via: 'post'
  match '/p_new_bom', to: 'procurement#p_upbom',via: 'get'
  match '/p_select_column', to: 'procurement#p_select_column',via: 'get' 
  match '/p_search_part', to: 'procurement#p_search_part',via: 'post'
  match '/p_viewbom', to: 'procurement#p_viewbom',via: 'get'
  match '/p_viewbom', to: 'procurement#p_viewbom',via: 'post'
  match '/p_update_bom', to: 'procurement#update_bom',via: 'post'
  match '/p_get_bom', to: 'procurement#p_get_bom',via: 'get'
  match '/p_del_bom', to: 'procurement#p_del_bom',via: 'post'
  match '/p_add_bom', to: 'procurement#p_add_bom',via: 'post'
  match '/p_bomlist', to: 'procurement#p_bomlist',via: 'get'
  match '/search_m', to: 'procurement#search_m',via: 'post'
  match '/search_m', to: 'procurement#search_m',via: 'get'
  match '/p_update', to: 'procurement#p_update',via: 'get'
  match '/p_updateii', to: 'procurement#p_updateii',via: 'get'
  match '/p_edit', to: 'procurement#p_edit',via: 'post'
  match '/p_up_userdo', to: 'procurement#p_up_userdo',via: 'get'
  match '/del_dn', to: 'procurement#del_dn',via: 'get'
  match '/p_edit_dn', to: 'procurement#p_edit_dn',via: 'post'
  match '/up_check', to: 'procurement#up_check',via: 'post'
  match '/p_excel', to: 'procurement#p_excel',via: 'get'
  match '/p_profit', to: 'procurement#p_profit',via: 'post'
  match '/del_cost', to: 'procurement#del_cost',via: 'get'
  match '/up_check', to: 'procurement#up_check',via: 'get'
  match '/p_edit_mpn', to: 'procurement#p_edit_mpn',via: 'post'
  match '/copy_data', to: 'procurement#copy_data',via: 'get'
  match '/p_del_bb', to: 'procurement#p_del_bb',via: 'get'
  match '/procurement/select_with_ajax', to: 'procurement#select_with_ajax', via: 'post'
  match '/procurement/select_with_ajax', to: 'procurement#select_with_ajax', via: 'get'
  match '/add_moko_part', to: 'procurement#add_moko_part', via: 'get'
  match '/add_moko_part', to: 'procurement#add_moko_part', via: 'post'
  match '/pj_edit', to: 'procurement#pj_edit', via: 'post'
  match '/add_order', to: 'procurement#add_order', via: 'get'
  match '/p_history', to: 'procurement#p_history', via: 'get'
  match '/p_edit_cost_dn', to: 'procurement#p_edit_cost_dn', via: 'post'
  match '/p_edit_supplier_dn', to: 'procurement#p_edit_supplier_dn', via: 'post'
  match '/supplier_offer', to: 'procurement#supplier_offer', via: 'get'
  match '/supplier_dn_excel', to: 'procurement#supplier_dn_excel', via: 'get'
  match '/part_list', to: 'procurement#part_list', via: 'get'
  match '/send_order_to_p', to: 'procurement#send_order_to_p', via: 'get'
  match '/remark_to_sell', to: 'procurement#remark_to_sell', via: 'get'
  match '/p_item_remark', to: 'procurement#p_item_remark', via: 'post'
  match '/p_item_remark_up', to: 'procurement#p_item_remark_up', via: 'post'
  match '/p_excel_add', to: 'procurement#p_excel_add', via: 'get'
  match '/supplier_d_list', to: 'procurement#supplier_d_list', via: 'get'
  match '/add_sd', to: 'procurement#add_sd', via: 'post'
  match '/update_sd', to: 'procurement#update_sd', via: 'post'
  match '/find_sd', to: 'procurement#find_sd', via: 'get'
  match '/sd_flow', to: 'procurement#sd_flow', via: 'get'
  match '/sd_back', to: 'procurement#sd_back', via: 'get'
  match '/update_p_data', to: 'procurement#update_p_data', via: 'get'



#external_bom
  match '/e_new', to: 'external_bom#p_create_bom', via: 'get' 
  match '/e_new_bom', to: 'external_bom#p_upbom',via: 'post'
  match '/e_new_bom', to: 'external_bom#p_upbom',via: 'get'
  match '/e_select_column', to: 'external_bom#p_select_column',via: 'get' 
  match '/e_search_part', to: 'external_bom#p_search_part',via: 'post'
  match '/e_viewbom', to: 'external_bom#p_viewbom',via: 'get'
  match '/e_viewbom', to: 'external_bom#p_viewbom',via: 'post'
  match '/e_update_bom', to: 'external_bom#update_bom',via: 'post'
  match '/e_get_bom', to: 'external_bom#p_get_bom',via: 'get'
  match '/e_del_bom', to: 'external_bom#p_del_bom',via: 'post'
  match '/e_add_bom', to: 'external_bom#p_add_bom',via: 'post'
  match '/e_bomlist', to: 'external_bom#p_bomlist',via: 'get'
  match '/e_search_m', to: 'external_bom#search_m',via: 'post'
  match '/e_search_m', to: 'external_bom#search_m',via: 'get'
  match '/e_update', to: 'external_bom#p_update',via: 'get'
  match '/e_updateii', to: 'external_bom#p_updateii',via: 'get'
  match '/e_edit', to: 'external_bom#p_edit',via: 'post'
  match '/e_up_userdo', to: 'external_bom#p_up_userdo',via: 'get'
  match '/e_del_dn', to: 'external_bom#del_dn',via: 'get'
  match '/e_edit_dn', to: 'external_bom#p_edit_dn',via: 'post'
  match '/e_up_check', to: 'external_bom#up_check',via: 'post'
  match '/e_excel', to: 'external_bom#p_excel',via: 'get'
  match '/e_profit', to: 'external_bom#p_profit',via: 'post'
  match '/e_del_cost', to: 'external_bom#del_cost',via: 'get'
  match '/e_up_check', to: 'external_bom#up_check',via: 'get'
  match '/e_edit_mpn', to: 'external_bom#p_edit_mpn',via: 'post'
  match '/e_copy_data', to: 'external_bom#copy_data',via: 'get'
  match '/e_del_bb', to: 'external_bom#p_del_bb',via: 'get'




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
  match '/viewbom', to: 'boms#viewbom',via: 'post'
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
  match '/del_bom', to: 'boms#del_bom',via: 'post'
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
