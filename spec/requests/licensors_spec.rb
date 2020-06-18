require 'rails_helper'

RSpec.describe Licensor, type: :request do
  let(:name) { 'ACME Breeding, Inc.' }
  let(:licensor_attributes) {
    {
      name: name
    }
  }

  describe 'GET /licensors' do
    it 'returns licensors' do
      get '/licensors', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /licensors' do
    let(:payload) {
      {
        data: {
          type: 'licensors',
          attributes: licensor_attributes
        }
      }.to_json
    }
    it 'creates licensor' do
      post '/licensors', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /licensors/:id' do
    let(:licensor) { create :licensor }
    let(:name) { 'Anvil, LLC' }
    let(:payload) {
      {
        data: {
          id: licensor.id,
          type: 'licensors',
          attributes: licensor_attributes
        }
      }.to_json
    }
    it 'updates licensor' do
      patch "/licensors/#{licensor.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /licensors/:id' do
    let(:licensor) { create :licensor }
    it 'updates licensor' do
      delete "/licensors/#{licensor.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Licensor.all.size).to eq(0)
    end
  end
end
