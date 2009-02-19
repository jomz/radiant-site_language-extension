require_dependency 'application'

include Globalize
Locale.set_base_language(SiteLanguage.default)

class SiteLanguageExtension < Radiant::Extension
  version "1.0"
  description "Habla Nederlands, sir? Si oder non?"
  url "http://openminds.be/"
  
  define_routes do |map|
    map.resources :site_languages, :path_prefix => "/admin"
    
    map.translated_page_edit 'admin/pages/edit/:id/:language', :controller => 'admin/pages', :action => 'edit'
    map.translated_snippet_edit 'admin/snippets/edit/:id/:language', :controller => 'admin/snippets', :action => 'edit'
    begin
      SiteLanguage.codes.each do |code|
        langname = Locale.new(code).language.code
        map.connect "#{langname}/*url", :controller => 'site', :action => 'show_page', :language => code
      end
    rescue
      #raise SiteLanguageError, "Migrations not ran yet.."
    end
  end

  def activate
    admin.tabs.add "Languages", "/admin/site_languages", :after => "Layouts", :visibility => [:admin, :developer]
    # We need globalize
    unless ActiveRecord::Base.respond_to? :translates
      raise SiteLanguageError, "Globalize does not appear to be installed."
    end
    enhance_classes
    
    admin.page.edit.add :main, 'page_edit_form_with_translated_target_url', :before => 'edit_form'
    admin.page.edit.main.delete('edit_form')
  end
  
  def deactivate
    admin.tabs.remove "Languages"
  end
  
  private
  
  def enhance_classes
    Admin::ResourceController.send :include, SiteLanguage::ControllerExtensions::ResourceControllerExtensions
    SiteController.send :include, SiteLanguage::ControllerExtensions::SiteControllerExtensions
    
    Page.send :include, SiteLanguage::PageExtensions
    Page.send :include, SiteLanguageTags
    
    Page.class_eval do
      translates :title, :breadcrumb, :slug, :keywords, :description
    end
    
    PagePart.class_eval do
      translates :content
    end
    
    Snippet.class_eval do
      translates :content
    end
  end
end