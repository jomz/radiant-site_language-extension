module SiteLanguage::ControllerExtensions

  module ResourceControllerExtensions
    
    def self.included(base)
      base.class_eval do
        def load_model # edit
          self.model = if params[:id]
            I18n.locale = (params[:language] || SiteLanguage.default).to_sym
            model_class.find(params[:id])
          else
            model_class.new
          end
        end
        
        def update
          I18n.locale = (params[:language]||SiteLanguage.default).to_sym
          params[model_symbol].each {|k,v| model.send("#{k}=", v)}
          model.save!
          I18n.locale = SiteLanguage.default
          announce_saved
          response_for :update
        end
        
        protected
        
        def continue_url(options)
          options[:redirect_to] || if params[:continue] && SiteLanguage.count > 0
            {:action => 'edit', :id => model.id, :language => (params[:language] || SiteLanguage.default)}
            else
              params[:continue] ? {:action => 'edit', :id => model.id} : {:action => "index"}
            end
        end
        
        def set_language
          I18n.locale = SiteLanguage.default
        end
        
      end
      base.before_filter :set_language, :only => [:index, :create, :new]
    end
    
  end
  
  module SiteControllerExtensions
    def self.included(base)
      base.class_eval do
        before_filter :set_language
        
        private

        def set_language
          if params[:language]
            I18n.locale = params[:language].to_sym
          else
            redirect_to :language => SiteLanguage.default, :url => (params[:url] unless params[:url] == '/'), :status => 301
          end
        end
      end
    end
    
  end
  
end