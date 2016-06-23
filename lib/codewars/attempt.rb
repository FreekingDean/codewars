module Codewars
  class Attempt < Codewars::BaseObject
    attribute :passed
    attribute :output
    attribute :summary, type: Hash
    attribute :passed, scope: :summary, inner_scope: :passed
    attribute :failed, scope: :summary, inner_scope: :failed
    attribute :errors, scope: :summary, inner_scope: :errors

    def to_s
      super+"\n"+parsed_output
    end

    def parsed_output
      "\n" +
      output.join("\n").
      gsub('<br>', "\n").
      gsub(/(<\/div>)?<div class=\'console-(passed|failed)\'>/, "\n").
      gsub("</div>", "\n\n")
    end
  end
end
