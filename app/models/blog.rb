require 'elasticsearch/model'

class Blog < ApplicationRecord 
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
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