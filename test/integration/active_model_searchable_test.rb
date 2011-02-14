require 'test_helper'

module Slingshot

  class ActiveModelSearchableIntegrationTest < Test::Unit::TestCase
    include Test::Integration

    def setup
      super
      SupermodelArticle.delete_all
      @model = SupermodelArticle.new :title => 'Test'
    end

    def teardown
      super
      SupermodelArticle.delete_all
    end

    include ActiveModel::Lint::Tests

    context "ActiveModel in :searchable mode" do

      setup    { Slingshot.index('supermodel_articles').delete }
      teardown { Slingshot.index('supermodel_articles').delete }

      should "save document into index on save and find it" do
        a = SupermodelArticle.new :title => 'Test'
        a.save
        # p a
        # puts a.id
        # p SupermodelArticle.find(a.id)

        Slingshot.index('supermodel_articles').refresh
        results = SupermodelArticle.search 'test'

        assert_equal 1, results.count

        assert_instance_of SupermodelArticle, results.first
        assert_equal 'Test', results.first.title
      end

      should "remove document from index on destroy" do
        a = SupermodelArticle.new :title => 'Test'
        a.save
        a.destroy

        Slingshot.index('supermodel_articles').refresh
        results = SupermodelArticle.search 'test'
        
        assert_equal 0, results.count
      end

      should "retrieve sorted documents by IDs returned from search" do
        SupermodelArticle.create! :title => 'foo'
        SupermodelArticle.create! :title => 'bar'

        Slingshot.index('supermodel_articles').refresh
        results = SupermodelArticle.search 'foo OR bar^100'
        p results
        assert_equal 2, results.count

        assert_equal 'bar', results.first.title
      end

    end

  end

end
