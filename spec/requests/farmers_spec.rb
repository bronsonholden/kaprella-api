require 'rails_helper'

RSpec.describe Farmer, type: :request do
  let(:name) { 'ACME, Inc.' }
  let(:farmer_attributes) {
    {
      name: name
    }
  }

  describe 'GET /farmers' do
    it 'returns farmers' do
      get '/farmers', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /farmers' do
    let(:payload) {
      {
        data: {
          type: 'farmers',
          attributes: farmer_attributes
        }
      }.to_json
    }
    it 'creates farmer' do
      post '/farmers', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /farmers/:id' do
    let(:farmer) { create :farmer }
    let(:name) { 'Anvil, LLC' }
    let(:payload) {
      {
        data: {
          id: farmer.id,
          type: 'farmers',
          attributes: farmer_attributes
        }
      }.to_json
    }
    it 'updates farmer' do
      patch "/farmers/#{farmer.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /farmers/:id' do
    let(:farmer) { create :farmer }
    it 'updates farmer' do
      delete "/farmers/#{farmer.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Farmer.all.size).to eq(0)
    end
  end
end
