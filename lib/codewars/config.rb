require 'yaml'

module Codewars
  def self.config(&block)
    block.call(configuration)
  end

  def self.configuration
    @configuration ||= Config.new
  end

  def self.configuration=(new_configuration)
    @configuration = new_configureation
  end

  def self.load_configuration(config_file_path)
    configuration.file_path = config_file_path
    return unless File.exist?(config_file_path)
    loaded_config = YAML.load_file(config_file_path)
    loaded_config ||= {}
    configuration.merge(loaded_config)
  end

  class Config
    CONFIG_OPTIONS = [:api_token, :editor, :username, :language]
    attr_reader :api_token, :editor, :username, :language, :file_path

    def initialize
      @file_path = nil
      @editor = ENV['EDITOR'] || 'vim'
      @api_token = ''
    end

    def merge(new_config)
      new_config.select!{|key,_| CONFIG_OPTIONS.include?(key.to_sym)}
      new_config.each do |key, val|
        send("#{key}=", val) if respond_to?("#{key}=")
      end
    end

    def save
      return if @file_path.nil?
      File.open(@file_path, 'w') {|f| f.write(self.to_hash.to_yaml) }
    end

    def file_path=(path)
      @file_path = path
    end

    def directory
      File.dirname(@file_path)
    end

    def api_token=(token)
      @api_token = token
    end

    def editor=(editor)
      @editor = editor
    end

    def username=(username)
      @username = username
    end

    def language=(language)
      @language = language
    end

    def to_hash
      CONFIG_OPTIONS.map do |option|
        [option.to_s, self.send(option).to_s]
      end.to_h
    end
  end
end
