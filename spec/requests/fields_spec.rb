require 'rails_helper'

RSpec.describe Field, type: :request do
  let(:farmer) { create :farmer }
  let(:field_name) { 'A-1' }
  let(:field_boundary) { 'MULTIPOLYGON (((-119.189632 35.091291,-119.181226 35.091291,-119.181058 35.084274,-119.189548 35.084309)))' }
  let(:field_attributes) {
    {
      name: field_name,
      boundary: field_boundary
    }
  }
  let(:field_relationships) {
    {
      farmer: {
        data: {
          id: farmer.id,
          type: 'farmer'
        }
      }
    }
  }

  describe 'GET /fields' do
    it 'returns fields' do
      get '/fields', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /fields' do
    let(:payload) {
      {
        data: {
          type: 'fields',
          attributes: field_attributes,
          relationships: field_relationships
        }
      }.to_json
    }
    it 'creates field' do
      post '/fields', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /fields/:id' do
    let(:field) { create :field }
    let(:field_name) { 'Z-10' }
    let(:payload) {
      {
        data: {
          id: field.id,
          type: 'fields',
          attributes: field_attributes
        }
      }.to_json
    }
    it 'updates field' do
      patch "/fields/#{field.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /fields/:id' do
    let(:field) { create :field }
    it 'updates field' do
      delete "/fields/#{field.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Field.all.size).to eq(0)
    end
  end
end
