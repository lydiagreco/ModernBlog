class Blog < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  enum status: { draft: 0, published: 1 }
  validates_presence_of :title, :body
  settings do
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
