Rails.application.routes.draw do
  get '/', to: 'application#api'
  api vendor_string: 'kaprella', default_version: 1, path: '' do
    version 1 do
      cache as: 'v1' do
        resources :farmers
        resources :fields
        resources :licensors
        resources :patents
        resources :plant_varieties, path: 'plant-varieties'
        resources :trademark_names, path: 'trademark-names'
      end
    end
  end
end
