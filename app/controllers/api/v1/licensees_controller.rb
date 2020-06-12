class Api::V1::LicenseesController < ApplicationController
  # GET /licensees
  def index
    scope = Licensee.all
    realizer = LicenseeRealizer.new(intent: :index, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true), status: :ok
  end

  # GET /licensees/:account_id
  def show
    scope = Licensee.all
    realizer = LicenseeRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /licensees
  def create
    realizer = LicenseeRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /licensees/:account_id
  def update
    scope = Licensee.all
    realizer = LicenseeRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /licensees/:account_id
  def destroy
    scope = Licensee.all
    realizer = LicenseeRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
