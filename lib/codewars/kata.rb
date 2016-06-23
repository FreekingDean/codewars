module Codewars
  class Kata < Codewars::BaseObject
    resource_name 'code-challenges/:id'

    attribute :id, scope: :slug
    attribute :slug
    attribute :name
    attribute :url
    attribute :description
    attribute :category
    attribute :languages, type: Array
    attribute :tags, type: Array
    attribute :rank, type: Hash
    attribute :rank_name, scope: :rank, inner_scope: :name
    attribute :creator_name, scope: :created_by, inner_scope: :username
    attribute :total_stars, type: Integer
    attribute :total_completed, type: Integer
    attribute :total_attempts, type: Integer

    def train language
      unless self.languages.include?(language)
        raise Codewars::LanguageNotFound.new(self, language)
      end

      Codewars::TrainableKata.train(self, language)
    end
  end
end
