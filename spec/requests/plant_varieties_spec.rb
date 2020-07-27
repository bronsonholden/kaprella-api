require 'rails_helper'

RSpec.describe PlantVariety, type: :request do
  let(:genus) { 'Vitis' }
  let(:denomination) { 'Fake Fruit One' }
  let(:plant_variety_attributes) {
    {
      genus: genus,
      denomination: denomination
    }
  }

  describe 'GET /plant-varieties' do
    it 'returns plant varieties' do
      get '/plant-varieties', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /plant-varieties' do
    let(:payload) {
      {
        data: {
          type: 'plant-varieties',
          attributes: plant_variety_attributes
        }
      }.to_json
    }
    it 'creates plant variety' do
      post '/plant-varieties', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /plant-varieties/:id' do
    let(:plant_variety) { create :plant_variety }
    let(:denomination) { 'Not Real One' }
    let(:payload) {
      {
        data: {
          id: plant_variety.id,
          type: 'plant-varieties',
          attributes: plant_variety_attributes
        }
      }.to_json
    }
    it 'updates plant variety' do
      patch "/plant-varieties/#{plant_variety.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /plant-varieties/:id' do
    let(:plant_variety) { create :plant_variety }
    it 'updates plant variety' do
      delete "/plant-varieties/#{plant_variety.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(PlantVariety.all.size).to eq(0)
    end
  end
end
