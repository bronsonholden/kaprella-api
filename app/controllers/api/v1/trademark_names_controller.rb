class Api::V1::TrademarkNamesController < ApplicationController
  # GET /trademark_names
  def index
    scope = TrademarkName.all
    realizer = TrademarkNameRealizer.new(intent: :index, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # GET /trademark_names/:id
  def show
    scope = TrademarkName.all
    realizer = TrademarkNameRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /trademark_names
  def create
    realizer = TrademarkNameRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /trademark_names/:id
  def update
    scope = TrademarkName.all
    realizer = TrademarkNameRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /trademark_names/:id
  def destroy
    scope = TrademarkName.all
    realizer = TrademarkNameRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
