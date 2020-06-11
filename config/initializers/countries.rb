ISO3166.configure do |config|
  # en: English
  # de: German
  # fr: French
  # es: Spanish
  # el: Greek
  # pt: Portuguese
  # af: Afrikaans
  # he: Hebrew
  config.locales = [:en, :de, :fr, :es, :el, :pt, :af, :he]
  config.enable_currency_extension!
end
