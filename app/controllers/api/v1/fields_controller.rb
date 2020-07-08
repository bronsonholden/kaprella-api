class Api::V1::FieldsController < ApplicationController
  # GET /fields
  def index
    scope = Field.all
    realizer = FieldRealizer.new(intent: :index, parameters: req_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: page), status: :ok
  end

  # GET /fields/:id
  def show
    scope = Field.all
    realizer = FieldRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /fields
  def create
    scope = Field.all
    realizer = FieldRealizer.new(intent: :create, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    # Field must be retrieved to include generated area column.
    object = Field.all.find(realizer.object.id)
    render json: JSONAPI::Serializer.serialize(object), status: :created
  end

  # PATCH/PUT /fields/:id
  def update
    scope = Field.all
    realizer = FieldRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /fields/:id
  def destroy
    scope = Field.all
    realizer = FieldRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
