class ApplicationController < ActionController::API

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
end
