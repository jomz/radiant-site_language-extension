# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require 'i18n_ext'

class SiteLanguageExtension < Radiant::Extension
  version "2.1"
  description "Habla Nederlands, sir? Si oder non?"
  url "http://openminds.be/"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :site_languages
    end
    
    map.translated_admin_page_edit 'admin/pages/:action/:id/:language', :controller => 'admin/pages', :id => /[0-9]+/, :action => /[a-z]+/
    map.translated_admin_snippet_edit 'admin/snippets/:action/:id/:language', :controller => 'admin/snippets', :id => /[0-9]+/, :action => /[a-z]+/
    begin
      SiteLanguage.codes.each do |code|
        map.connect "#{code.to_s}/*url", :controller => 'site', :action => 'show_page', :language => code
      end
    rescue
      #raise SiteLanguageError, "Migrations not ran yet.."
    end
  end
  
  def activate
    admin.tabs.add "Languages", "/admin/site_languages", :after => "Layouts", :visibility => [:all]
    
    unless ActiveRecord::Base.respond_to? :translates
      raise StandardError, "Globalize does not appear to be installed."
    end
        
    admin.page.index.add :node, 'node_title_with_language_links', :after => 'title_column'
    admin.page.index.node.delete('title_column')
    admin.page.edit.add :main, 'page_edit_form_with_translated_target_url', :before => 'edit_form'
    admin.page.edit.main.delete('edit_form')
    
    Admin::PagesController.send :include, SiteLanguage::ControllerExtensions::ResourceControllerExtensions
    Admin::SnippetsController.send :include, SiteLanguage::ControllerExtensions::ResourceControllerExtensions
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
    
    Radiant::Config['page.edit.published_date?'] = false # otherwise gives error on page save..
    I18n.fallbacks.defaults = [SiteLanguage.default] | SiteLanguage.codes
  end
  
  def deactivate
    admin.tabs.remove "Languages"
  end
  
end
