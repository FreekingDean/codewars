require 'open-uri'
module Codewars
  class TrainableKata < Codewars::Kata
    resource_name 'code-challenges/:id/:language/train'

    attribute :kata, ignore: true
    attribute :language
    attribute :session, type: Hash
    attribute :project_id, scope: :session, inner_scope: :projectId
    attribute :solution_id, scope: :session, inner_scope: :solutionId
    attribute :code, scope: :session, inner_scope: :code
    attribute :tests, scope: :session, inner_scope: :exampleFixture

    associate :kata, :creator_name
    associate :kata, :total_attempts
    associate :kata, :total_stars
    associate :kata, :total_completed
    associate :kata, :category
    associate :kata, :rank
    associate :kata, :rank_name

    def self.train kata, language
      resp = conn.post do |req|
        req.url [
          "#{Codewars::BaseObject::BASE_API}",
          "#{replace_identifiers(@resource_name, {id: kata.slug, language: language})}"
        ].join('/')
      end
      data = parse_response(resp)

      self.new(data, kata: kata).tap do |trainable|
        trainable.language = language
      end
    end

    def initialize(data, kata:)
      self.kata = kata
      super(data)
    end

    def train(reset: false)
      Codewars::EditorUtil.open(self, replace: reset ? :all : :none)
    end

    def attempt
      resp = self.class.conn.post do |req|
        req.url "#{Codewars::BaseObject::BASE_API}/code-challenges/projects/#{self.project_id}/solutions/#{self.solution_id}/attempt"
        req.body = URI.encode_www_form('code' => Codewars::FileUtil.get_code(self))
      end
      parsed_reponse = self.class.parse_response(resp)

      raise Codewars::ConnectionError.new unless parsed_reponse[:success]
      Codewars::Attempt.new(self.class.get_deffered_response(parsed_reponse[:dmid]))
    end

    def finalize
      resp = self.class.conn.post do |req|
        req.url "#{Codewars::BaseObject::BASE_API}/code-challenges/projects/#{self.project_id}/solutions/#{self.solution_id}/finalize"
      end
      puts self.class.parse_response(resp)
    end

    def to_s
      super + "\nTests: #{self.tests}\n" +
      "Code: #{self.code}"
    end
  end
end
