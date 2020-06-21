class Api::V1::LicensorsController < ApplicationController
  # GET /licensors
  def index
    scope = Licensor.all
    realizer = LicensorRealizer.new(intent: :index, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # GET /licensors/:id
  def show
    scope = Licensor.all
    realizer = LicensorRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /licensors
  def create
    realizer = LicensorRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /licensors/:id
  def update
    scope = Licensor.all
    realizer = LicensorRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /licensors/:id
  def destroy
    scope = Licensor.all
    realizer = LicensorRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
