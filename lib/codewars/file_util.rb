require 'yaml'
module Codewars
  class FileUtil
    SESSION_FILE = '.session'
    CODE_FILE = 'code.rb'
    TEST_FILE = 'tests.rb'
    DESCRIPTION_FILE = 'description.txt'

    def self.load_session(kata)
      session_path = File.join(Codewars.configuration.file_path, kata.slug, SESSION_FILE)
      return YAML.load_file(session_path) if File.exist?(session_path)
      return false
    end

    def self.new_session(kata, session)
      kata_dir = self.get_kata_dir(kata)
      File.open(File.join(kata_dir, SESSION_FILE), 'w') do |f|
        f.write( { } ).to_yaml
      end
    end

    def self.get_kata_dir(kata)
      kata_dir = File.join(Codewars.configuration.directory, kata.slug)
      FileUtils.mkdir_p(kata_dir) unless File.directory?(kata_dir)
      kata_dir
    end

    def self.get_code_file(kata)
      get_kata_file(kata, CODE_FILE, kata.code)
    end

    def self.get_code(kata)
      kata_dir = self.get_kata_dir(kata)
      file_path = File.join(kata_dir, CODE_FILE)
      File.read(file_path)
    end

    def self.get_description_file(kata)
      get_kata_file(kata, DESCRIPTION_FILE, kata.description)
    end

    def self.get_test_file(kata)
      get_kata_file(kata, TEST_FILE, kata.tests)
    end

    def self.get_kata_file(kata, filename, newfile_contents)
      kata_dir = self.get_kata_dir(kata)
      file_path = File.join(kata_dir, filename)
      return file_path if File.exist?(file_path)
      File.open(file_path, 'w') do |f|
        f.write newfile_contents
      end
      file_path
    end
  end
end
