module Codewars
  class Error < StandardError
  end
  class ConnectionError < Codewars::Error
    def initialize(message=nil)
      if message.nil?
        super("Error talking to Codewars server")
      else
        super(message)
      end
    end
  end

  class LanguageNotFound < Codewars::Error
    def initialize(kata, language)
      super("Can't find #{language} for kata #{kata.name} please choose one of: #{kata.languages.join(', ')}")
    end
  end

  class NotFound < Codewars::Error
    def initialize(klass, kata_id)
      super("Can't find #{klass.name.split('::').last.downcase} with id/slug #{kata_id}")
    end
  end
end
