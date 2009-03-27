class SiteLanguage < ActiveRecord::Base
  class << self
    def codes
      find(:all).collect { |sl| sl.code }
    end

    def default
      'en'
    end
  end
  
  def validate
    errors.add("code", "has invalid format. Valid examples are 'nl-BE' and 'en-US'") if code !~ /^[a-zA-Z0-9\-]+$/
  end
  
end
