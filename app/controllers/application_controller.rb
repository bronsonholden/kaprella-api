class ApplicationController < ActionController::API
  rescue_from Kaprella::Errors::RestrictedGeneratedColumnIdentifier, with: :api_exception
  rescue_from Kaprella::Errors::InvalidGeneratedColumnIdentifier, with: :api_exception
  rescue_from Kaprella::Errors::GeneratorFunctionArgumentError, with: :api_exception
  rescue_from Kaprella::Errors::UnknownPropertyIdentifier, with: :api_exception
  rescue_from Kaprella::Errors::InvalidFilterExpression, with: :api_exception
  rescue_from Kaprella::Errors::InvalidSortExpression, with: :api_exception

  def api
    render json: {
      'data' => {
        'type' => 'api',
        'attributes' => {
          'version' => Api::VERSION
        }
      }
    }, status: :ok
  end

  protected

  def req_params
    params = request.params

    if !params.key?('page')
      params['page'] = {
        'limit' => 10,
        'offset' => 0
      }
    else
      page = params.fetch('page')

      if !page.key?('limit')
        page['limit'] = 10
      else
        page['limit'] = page.fetch('limit').to_i
      end

      if !page.key?('offset')
        page['offset'] = 0
      else
        page['offset'] = page.fetch('offset').to_i
      end
    end

    params
  end

  def page_limit
    req_params.dig('page', 'limit')
  end

  def page_offset
    req_params.dig('page', 'offset')
  end

  def api_exception(exception)
    errors = [{ title: exception.message }]
    render json: { errors: errors }, status: exception.status
  end
end
