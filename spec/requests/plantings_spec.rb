require 'rails_helper'

RSpec.describe Planting, type: :request do
  let(:notes) { 'Notes' }
  let(:active) { true }
  let(:planting_attributes) {
    {
      active: active,
      notes: notes
    }
  }
  let(:field) { create :field }
  let(:planting_relationships) {
    {
      field: {
        data: {
          id: field.id,
          type: 'fields'
        }
      }
    }
  }

  describe 'GET /plantings' do
    it 'returns plantings' do
      get '/plantings', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /plantings' do
    let(:payload) {
      {
        data: {
          type: 'plantings',
          attributes: planting_attributes,
          relationships: planting_relationships
        }
      }.to_json
    }
    it 'creates planting' do
      post '/plantings', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /plantings/:id' do
    let(:planting) { create :planting }
    let(:notes) { 'Other notes' }
    let(:payload) {
      {
        data: {
          id: planting.id,
          type: 'plantings',
          attributes: planting_attributes
        }
      }.to_json
    }
    it 'updates planting' do
      patch "/plantings/#{planting.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /plantings/:id' do
    let(:planting) { create :planting }
    it 'updates planting' do
      delete "/plantings/#{planting.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Planting.all.size).to eq(0)
    end
  end
end
