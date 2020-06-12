require 'rails_helper'

RSpec.describe Licensee, type: :request do
  let(:name) { 'ACME, Inc.' }
  let(:country) { 'US' }
  let(:licensee_attributes) {
    {
      name: name,
      country: country
    }
  }

  describe 'GET /licensees' do
    it 'returns licensees' do
      get '/licensees', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /licensees' do
    let(:payload) {
      {
        data: {
          type: 'licensees',
          attributes: licensee_attributes
        }
      }.to_json
    }
    it 'creates licensee' do
      post '/licensees', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /licensees/:id' do
    let(:licensee) { create :licensee }
    let(:name) { 'Anvil, LLC' }
    let(:payload) {
      {
        data: {
          id: licensee.id,
          type: 'licensees',
          attributes: licensee_attributes
        }
      }.to_json
    }
    it 'updates licensee' do
      patch "/licensees/#{licensee.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /licensees/:id' do
    let(:licensee) { create :licensee }
    it 'updates licensee' do
      delete "/licensees/#{licensee.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Licensee.all.size).to eq(0)
    end
  end
end
