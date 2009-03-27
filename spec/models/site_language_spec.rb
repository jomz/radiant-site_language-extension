require File.dirname(__FILE__) + '/../spec_helper'

describe SiteLanguage do
  before(:each) do
    @site_language = SiteLanguage.new
  end

  it "should be valid" do
    @site_language.should be_valid
  end
end
