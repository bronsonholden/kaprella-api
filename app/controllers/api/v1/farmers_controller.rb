class Api::V1::FarmersController < ApplicationController
  # GET /farmers
  def index
    scope = Farmer.all.includes(:fields)
    realizer = FarmerRealizer.new(intent: :index, parameters: request.params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: page), status: :ok
  end

  # GET /farmers/:id
  def show
    scope = Farmer.all
    realizer = FarmerRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /farmers
  def create
    realizer = FarmerRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /farmers/:id
  def update
    scope = Farmer.all
    realizer = FarmerRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /farmers/:id
  def destroy
    scope = Farmer.all
    realizer = FarmerRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
