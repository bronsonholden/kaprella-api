class Api::V1::PatentsController < ApplicationController
  # GET /patents
  def index
    scope = Patent.all
    realizer = PatentRealizer.new(intent: :index, parameters: request.params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: page), status: :ok
  end

  # GET /patents/:id
  def show
    scope = Patent.all
    realizer = PatentRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /patents
  def create
    realizer = PatentRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /patents/:id
  def update
    scope = Patent.all
    realizer = PatentRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /patents/:id
  def destroy
    scope = Patent.all
    realizer = PatentRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
