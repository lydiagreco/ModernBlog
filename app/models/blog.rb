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

  
  index_name Rails.application.class.parent_name.underscore
  document_type self.name.downcase

  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :title, analyzer: 'english'
      indexes :body, analyzer: 'english'
      indexes :published, type: :boolean
    end
  end
  
  enum status: { draft: 0, published: 1 }
  extend FriendlyId
  friendly_id :title, use: :slugged
  validates_presence_of :title, :body
  
  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^5', 'body']
          }
        },
        highlight: {
          pre_tags: ['<mark>'],
          post_tags: ['</mark>'],
          fields: {
            title: {},
            body: {},
          }
        },
        suggest: {
          text: query,
          title: {
            term: {
              size: 1,
              field: :title
            }
          },
          body: {
            term: {
              size: 1,
              field: :body
            }
          }
        }
      }
    )
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [ :title, :body ] )
  end

    # Delete the previous articles index in Elasticsearch
  Blog.__elasticsearch__.client.indices.delete index: Blog.index_name rescue nil

  # Create the new index with the new mapping
  Blog.__elasticsearch__.client.indices.create \
    index: Blog.index_name,
    body: { settings: Blog.settings.to_hash, mappings: Blog.mappings.to_hash }

  # Index all article records from the DB to Elasticsearch
  Blog.import
end