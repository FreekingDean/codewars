require 'thor'
require 'codewars'

module Codewars
  class CLI < Thor
    class_option :config_dir
    class_option :username
    class_option :api_key
    class_option :save, aliases: :s, type: :boolean

    def initialize(*args)
      super(*args)
      find_or_init_config
    end

    desc "login API_KEY", "login will really only ask you for your api token. There is realy no use in this unless saving."
    long_desc <<-LONGDESC
      `login`    Will really only ask you for your api token.
                 There is realy no use in this unless saving.
    LONGDESC
    def login(api_token)
      Codewars.configuration.api_token = api_token
      Codewars.configuration.save
    end

    desc "me", "me will pull your user data down from codewars."
    def me
      if Codewars.configuration.username.nil?
        puts "Username not set. Please add it to your config directory #{@config_dir}"
      end
      puts Codewars::User.find(Codewars.configuration.username)
    rescue Codewars::Error => ex
      puts ex.message
    end

    desc "kata KATA_ID/SLUG", "kata will pull kata information data down from codewars."
    def kata(kata_id)
      puts Codewars::Kata.find(kata_id)
    rescue Codewars::Error => ex
      puts ex.message
    end

    desc "train KATA_ID/SLUG", "train will start the training for the specified kata"
    option :language, alias: :l, banner: 'RUBY'
    option :reset, alias: :r, type: :boolean
    def train(kata_id)
      kata = Kata.find(kata_id)
      language = options[:language] || Codewars.configuration.language
      if language.nil?
        user = Codewars::User.find(Codewars.configuration.username)
        language = user.best_language
      end
      trainable = kata.train(language)
      trainable.train(reset: options[:reset])
    rescue Codewars::Error => ex
      puts ex.message
    end

    desc "attempt KATA_ID/SLUG", "attempt will attempt the current solution for the specified kata"
    option :language, alias: :l, banner: 'RUBY'
    def attempt(kata_id)
      kata = Kata.find(kata_id)
      language = options[:language] || Codewars.configuration.language
      if language.nil?
        user = Codewars::User.find(Codewars.configuration.username)
        language = user.best_language
      end
      puts kata.train(language).attempt
    rescue Codewars::Error => ex
      puts ex.message
    end

    desc "finalize KATA_ID/SLUG", "finalize will finalize the current solution for the specified kata"
    option :language, alias: :l, banner: 'RUBY'
    def finalize(kata_id)
      kata = Kata.find(kata_id)
      language = options[:language] || Codewars.configuration.language
      if language.nil?
        user = Codewars::User.find(Codewars.configuration.username)
        language = user.best_language
      end
      puts kata.train(language).finalize
    rescue Codewars::Error => ex
      puts ex.message
    end

    private
    def find_or_init_config
      @config_dir = options[:config_dir] || "#{ENV.fetch('HOME')}/.codewars"
      unless options[:config_dir].nil? || File.directory?(options[:config_dir])
        puts "Could find config directory: #{options[:config_dir]}"
        return
      end
      FileUtils.mkdir_p(@config_dir) unless File.directory?(@config_dir)

      Codewars.load_configuration(File.join(@config_dir, "config.yml"))
      Codewars.configuration.api_key = options[:api_key] if options[:api_key]
      Codewars.configuration.username = options[:username] if options[:username]
      Codewars.configuration.save if options[:save]
    end
  end
end
