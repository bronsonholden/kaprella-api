require 'rails_helper'

RSpec.describe TrademarkName, type: :request do
  let(:authority) { 'ACMEtopia Patent Office' }
  let(:title) { 'Superb-anana' }
  let(:mark) { 'Superb-anana' }
  let(:grant_date) { Date.today }
  let(:renewal_date) { grant_date + 10.years }
  let(:trademark_name_attributes) {
    {
      title: title,
      authority: authority,
      mark: mark,
      grant_date: grant_date,
      renewal_date: renewal_date
    }
  }
  let(:plant_variety) { create :plant_variety }
  let(:trademark_name_relationships) {
    {
      subject: {
        data: {
          id: plant_variety.id,
          type: 'plantVarieties'
        }
      }
    }
  }

  describe 'GET /trademarkNames' do
    it 'returns trademark names' do
      get '/trademarkNames', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /trademarkNames' do
    let(:payload) {
      {
        data: {
          type: 'trademarkNames',
          attributes: trademark_name_attributes,
          relationships: trademark_name_relationships
        }
      }.to_json
    }
    it 'creates trademark name' do
      post '/trademarkNames', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /trademarkNames/:id' do
    let(:trademark_name) { create :trademark_name }
    let(:mark) { 'Superb-anana II' }
    let(:payload) {
      {
        data: {
          id: trademark_name.id,
          type: 'trademarkNames',
          attributes: trademark_name_attributes
        }
      }.to_json
    }
    it 'updates trademark name' do
      patch "/trademarkNames/#{trademark_name.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /trademarkNames/:id' do
    let(:trademark_name) { create :trademark_name }
    it 'updates trademark name' do
      delete "/trademarkNames/#{trademark_name.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(TrademarkName.all.size).to eq(0)
    end
  end
end
