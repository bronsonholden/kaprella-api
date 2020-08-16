class Api::V1::LicensorsController < ApplicationController
  # GET /licensors
  def index
    scope = Licensor.all
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = LicensorRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(Licensor)
    filters = FilterHumanizeMetaService.new(Licensor, params['filter'])
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate,
      'filterLabels' => filters.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, is_collection: true, meta: meta), status: :ok
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
