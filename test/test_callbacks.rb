require 'test_helper'

include ActiveSupport::Callbacks

class CallbacksTest < Test::Unit::TestCase
  context "Defining and running callbacks" do
    setup do
      @document = Class.new
      @document.class_eval do
        include MongoMapper::Document
        
        key :name, String
        
        %w(before_create after_create before_update after_update 
           before_save after_save before_destroy after_destroy).each do |callback|
          callback_method = "#{callback}_callback"
          send(callback, callback_method)
          define_method(callback_method) do
            history << callback.to_sym
          end
        end
        
        def history
          @history ||= []
        end
      end
      @document.collection.clear
    end

    should "work for before and after create" do
      doc = @document.create(:name => 'John Nunemaker')
      doc.history.should include(:before_create)
      doc.history.should include(:after_create)
    end
    
    should "work for before and after update" do
      doc = @document.create(:name => 'John Nunemaker')
      doc.name = 'John Doe'
      doc.save
      doc.history.should include(:before_update)
      doc.history.should include(:after_update)
    end
    
    should "work for before and after save" do
      doc = @document.new
      doc.name = 'John Doe'
      doc.save
      doc.history.should include(:before_save)
      doc.history.should include(:after_save)
    end
    
    should "work for before and after destroy" do
      doc = @document.create(:name => 'John Nunemaker')
      doc.destroy
      doc.history.should include(:before_destroy)
      doc.history.should include(:after_destroy)
    end
  end
  
end