class SiteLanguage < ActiveRecord::Base
  class << self
    def codes
      find(:all).collect { |sl| sl.code }
    end

    def default
      Radiant::Config['site_language.default_language'] || 'en'
    end
  end
  
  def validate
    errors.add("code", "has invalid format. Valid examples are 'nl-BE' and 'en-US'") if code !~ /^[a-zA-Z0-9\-]+$/
  end
  
end
