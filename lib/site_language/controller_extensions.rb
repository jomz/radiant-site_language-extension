module SiteLanguage::ControllerExtensions

  module ResourceControllerExtensions
    
    def self.included(base)
      base.class_eval do
        
        def load_model
          self.model = if params[:id]
            #debugger
            Locale.set(params[:language] || SiteLanguage.default)
            model_class.find(params[:id])
          else
            model_class.new
          end
        end
        
        protected
  
        def continue_url(options)
          options[:redirect_to] || if params[:continue] && SiteLanguage.count > 0
            {:action => 'edit', :id => model.id, :language => (params[:language] || SiteLanguage.default)}
            else
              params[:continue] ? {:action => 'edit', :id => model.id} : {:action => "index"}
            end
        end
        
      end
    end
    
  end
  
  module SiteControllerExtensions
    def self.included(base)
      base.class_eval do
        before_filter :set_language
        
        def show_page
          response.headers.delete('Cache-Control')
          url = params[:url]
          if Array === url
            url = url.join('/')
          else
            url = url.to_s
          end
          lang = params[:language].to_s
          if (request.get? || request.head?) and live? and (@cache.response_cached?(lang + '/' + url))
            @cache.update_response(lang + '/' + url, response, request)
            @performed_render = true
          else
            show_uncached_page(url, lang)
          end
        end
        
        private

        def show_uncached_page(url, lang)
          @page = find_page(url)
          unless @page.nil?
            process_page(@page)
            @cache.cache_response(lang + '/' + url, response) if request.get? and live? and @page.cache?
            @performed_render = true
          else
            render :template => 'site/not_found', :status => 404
          end
        rescue Page::MissingRootPageError
          redirect_to welcome_url
        end
        
        def set_language
          (redirect_to :language => SiteLanguage.default, 
            :url => (params[:url] unless params[:url] == '/'),
            :status=>301
            ) unless Locale.set(params[:language]) || SiteLanguage.count < 1
        end
      end
    end
    
  end
  
end