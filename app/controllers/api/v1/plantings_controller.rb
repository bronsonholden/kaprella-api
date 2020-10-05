class Api::V1::PlantingsController < ApplicationController
  # GET /plantings
  def index
    scope = Planting.all
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = PlantingRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(Planting)
    filters = FilterHumanizeMetaService.new(Planting, params['filter'])
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate,
      'filterLabels' => filters.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: meta), status: :ok
  end

  # GET /plantings/:id
  def show
    scope = Planting.all
    realizer = PlantingRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /plantings
  def create
    realizer = PlantingRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :created
  end

  # PATCH/PUT /plantings/:id
  def update
    scope = Planting.all
    realizer = PlantingRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.save!
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # DELETE /plantings/:id
  def destroy
    scope = Planting.all
    realizer = PlantingRealizer.new(intent: :update, parameters: request.params, headers: request.headers, scope: scope)
    realizer.object.destroy
  end
end
