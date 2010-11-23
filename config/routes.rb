map.namespace :admin do |admin|
  admin.resources :reports, :collection => {
    :revenue => :get,
    :units => :get,
    :profit => :get,
    :top_products => :get,
    :top_customers => :get,
    :geo_revenue => :get,
    :geo_units => :get,
    :geo_profit => :get,
  }
end
