Rails.application.routes.draw do
  api vendor_string: 'kaprella', default_version: 1, path: '' do
    version 1 do
      cache as: 'v1' do
        resources :licensees
      end
    end
  end
end
