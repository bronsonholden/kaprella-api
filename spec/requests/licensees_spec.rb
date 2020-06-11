require 'rails_helper'

RSpec.describe Licensee, type: :request do
  describe 'GET /licensees' do
    it 'returns licensees' do
      get '/licensees', headers: headers
      expect(response).to have_http_status(200)
    end
  end
end
