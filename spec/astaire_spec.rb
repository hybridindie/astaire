require 'helper'

describe "Astaire::DSL" do
  def build_app(&blk)
    app = Class.new(ActionController::Base) { include Astaire::DSL }
    app.class_eval(&blk)
    @app = Rack::Lint.new(app)
  end

  METHODS = %w(get post put delete)

  before :each do
    build_app do
      METHODS.each do |method|
        send(method, "/ima_#{method}") do
          render :text => "#{method}: hello"
        end
      end

      get "/hello", :as => :hello do
        render :text => "hello"
      end

      get "/hello_path" do
        render :text => hello_path
      end

      get "/hello_url" do
        render :text => hello_url
      end
    end
  end

  METHODS.each do |method|
    describe "##{method}" do
      it "successfully calls a valid action with a correct method" do
        send(method, "/ima_#{method}")
        last_response.body.should == "#{method}: hello"
      end

      it "does not call a valid action with an incorrect method" do
        (METHODS - [method]).each do |m|
          send(m, "/ima_#{method}")
          last_response.status.should == 404
        end
      end

      it "does not call an invalid action with a correct method" do
        METHODS.each do |m|
          send(m, "/ima")
          last_response.status.should == 404
        end
      end
    end
  end

  describe "generating URLs" do
    it "provides <name>_path" do
      get "/hello_path"
      last_response.body.should == "/hello"
    end

    it "provides <name>_url" do
      get "/hello_url"
      last_response.body.should == "http://example.org/hello"
    end
  end
end