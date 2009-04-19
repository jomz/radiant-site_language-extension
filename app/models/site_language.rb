class SiteLanguage < ActiveRecord::Base
  class << self
    def codes
      find(:all).collect { |sl| sl.code }
    end

    def default
      Radiant::Config['site_language.default_language'] || 'en'
    end
  end
  
  def to_sym
    code.to_sym
  end
  
end
