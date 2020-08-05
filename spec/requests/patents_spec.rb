require 'rails_helper'

RSpec.describe Patent, type: :request do
  let(:title) { 'Secret Groundbreaking Invention' }
  let(:patent_number) { 'APO-0001' }
  let(:expiration_date) { Date.today + 10.years }
  let(:authority) { 'ACMEtopia Patent Office' }
  let(:patent_attributes) {
    {
      title: title,
      authority: authority,
      patent_number: patent_number,
      expiration_date: expiration_date
    }
  }
  let(:licensor) { create :licensor }
  let(:plant_variety) { create :plant_variety }
  let(:patent_relationships) {
    {
      assignee: {
        data: {
          id: licensor.id,
          type: 'licensor'
        }
      },
      subject: {
        data: {
          id: plant_variety.id,
          type: 'plantVarieties'
        }
      }
    }
  }

  describe 'GET /patents' do
    it 'returns patents' do
      get '/patents', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /patents' do
    let(:payload) {
      {
        data: {
          type: 'patents',
          attributes: patent_attributes,
          relationships: patent_relationships
        }
      }.to_json
    }
    it 'creates patent' do
      post '/patents', headers: headers, params: payload
      expect(response).to have_http_status(201)
    end
  end

  describe 'PATCH /patents/:id' do
    let(:patent) { create :patent }
    let(:title) { 'My Second Best Invention' }
    let(:payload) {
      {
        data: {
          id: patent.id,
          type: 'patents',
          attributes: patent_attributes
        }
      }.to_json
    }
    it 'updates patent' do
      patch "/patents/#{patent.id}", headers: headers, params: payload
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE /patents/:id' do
    let(:patent) { create :patent }
    it 'updates patent' do
      delete "/patents/#{patent.id}", headers: headers
      expect(response).to have_http_status(204)
      expect(Patent.all.size).to eq(0)
    end
  end
end
