class Api::V1::FieldsController < ApplicationController
  # GET /fields
  def index
    scope = Field.with_generated_columns.includes(:farmer)
    params = req_params
    realizer_params = params.except('filter', 'sort')
    scope = ResourceQueryService.new(params).apply(scope)
    realizer = FieldRealizer.new(intent: :index, parameters: realizer_params, headers: request.headers, scope: scope)
    page = PaginationMetaService.new(page_offset, page_limit, realizer.total_count)
    reflection = ReflectionMetaService.new(Field)
    filters = FilterHumanizeMetaService.new(Field, params['filter'])
    meta = {
      'page' => page.generate,
      'reflection' => reflection.generate,
      'filterLabels' => filters.generate
    }
    render json: JSONAPI::Serializer.serialize(realizer.object, include: ['farmer'], is_collection: true, meta: meta), status: :ok
  end

  # GET /fields/:id
  def show
    scope = Field.with_generated_columns
    realizer = FieldRealizer.new(intent: :show, parameters: request.params, headers: request.headers, scope: scope)
    render json: JSONAPI::Serializer.serialize(realizer.object), status: :ok
  end

  # POST /fields
  def create
    realizer = FieldRealizer.new(intent: :create, parameters: request.params, headers: request.headers)
    realizer.object.save!
    # Field must be retrieved to include generated area column.
    object = Field.with_generated_columns.find(realizer.object.id)
    render json: JSONAPI::Serializer.serialize(object), status: :created
  end

  # PATCH/PUT /fields/:id
  def update
    scope = Field.with_generated_columns
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
