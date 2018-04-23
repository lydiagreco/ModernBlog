require 'elasticsearch/model'

class Blog < ApplicationRecord 
  include Elasticsearch::Model
  after_commit on: [:create] do
    begin
      __elasticsearch__.index_document
    rescue Exception => ex
      logger.error "ElasticSearch after_commit error on create: #{ex.message}"
    end
  end

  after_commit on: [:update] do
    begin
      Elasticsearch::Model.client.exists?(index: 'articles', type: 'article', id: self.id) ? __elasticsearch__.update_document :     __elasticsearch__.index_document
    rescue Exception => ex
      logger.error "ElasticSearch after_commit error on update: #{ex.message}"
    end
  end

  after_commit on: [:destroy] do
    begin
      __elasticsearch__.delete_document
    rescue Exception => ex
      logger.error "ElasticSearch after_commit error on delete: #{ex.message}"
    end
  end

  enum status: { draft: 0, published: 1 }
  validates_presence_of :title, :body
  settings do |blog|
    mappings dynamic: false do
      indexes :author, type: :text
      indexes :title, type: :text, analyzer: :english
      indexes :body, type: :text, analyzer: :english
      indexes :tags, type: :text, analyzer: :english
      indexes :published, type: :boolean
    end
  end

  def self.search_published(query)
   self.search({
     query: {
       bool: {
         must: [
         {
           multi_match: {
             query: query,
             fields: [:author, :title, :body, :tags]
           }
         },
         {
           match: {
             published: true
           }
         }]
       }
     }
   })
 end
end

