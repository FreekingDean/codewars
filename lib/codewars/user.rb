module Codewars
  class User < Codewars::BaseObject
    resource_name 'users/:id'

    attribute :username
    attribute :name
    attribute :honor, type: Integer
    attribute :clan
    attribute :leaderboard_position, type: Integer
    attribute :skills, type: Array
    attribute :ranks, type: Hash
    attribute :languages
    attribute :authord_challenges, scope: :code_challenges, inner_scope: :totalAuthored
    attribute :completed_challenges, scope: :code_challenges, inner_scope: :totalCompleted

    def best_language
      self.ranks[:languages].max_by{|_, language| language[:rank].to_i}.first.to_s
    end

    def languages
      self.ranks[:languages].keys.map(&:to_s)
    end
  end
end
