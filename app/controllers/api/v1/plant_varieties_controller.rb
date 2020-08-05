class Api::V1::PlantVarietiesController < ApplicationController
  # GET /plant_varieties
  def index
    scope = PlantVariety.with_protections
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = PlantVarietyRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(PlantVariety)
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: meta), status: :ok
  end

  # GET /plant_varieties/:id
  def show
    scope = PlantVariety.with_protections
    realizer = PlantVarietyRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /plant_varieties
  def create
    realizer = PlantVarietyRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /plant_varieties/:id
  def update
    scope = PlantVariety.with_protections
    realizer = PlantVarietyRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /plant_varieties/:id
  def destroy
    scope = PlantVariety.with_protections
    realizer = PlantVarietyRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
