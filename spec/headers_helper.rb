module HeadersHelper
  def headers(api_version: 1)
    {
      'Content-Type' => "application/vnd.kaprella+json; version=#{api_version}"
    }
  end
end
