class Api::V1::TrademarkNamesController < ApplicationController
  # GET /trademark_names
  def index
    scope = TrademarkName.all
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = TrademarkNameRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(TrademarkName)
    filters = FilterHumanizeMetaService.new(TrademarkName, params['filter'])
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate,
      'filterLabels' => filters.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: meta), status: :ok
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
