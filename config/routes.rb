Rails.application.routes.draw do
  get '/', to: 'application#api'
  api vendor_string: 'kaprella', default_version: 1, path: '' do
    version 1 do
      cache as: 'v1' do
        [
          :farmers,
          :fields,
          :licensors,
          :patents,
          :plant_varieties,
          :plantings,
          :trademark_names
        ].each { |resource|
          resources resource, path: resource.to_s.camelize(:lower)
        }
      end
    end
  end
end
