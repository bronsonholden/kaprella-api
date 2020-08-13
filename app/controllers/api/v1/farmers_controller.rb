class Api::V1::FarmersController < ApplicationController
  # GET /farmers
  def index
    scope = Farmer.with_generated_columns
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = FarmerRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(Farmer)
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: meta), status: :ok
  end

  # GET /farmers/:id
  def show
    scope = Farmer.with_generated_columns
    realizer = FarmerRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /farmers
  def create
    realizer = FarmerRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    object = Farmer.with_generated_columns.find(realizer.object.id)
    render json: JSONAPI::Serializer.serialize(object), status: :created
  end

  # PATCH/PUT /farmers/:id
  def update
    scope = Farmer.with_generated_columns
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
