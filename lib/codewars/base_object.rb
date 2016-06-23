require 'json'

module Codewars
  class BaseObject
    BASE_API = "api/v1"

    def initialize(data)
      self.class.attributes.each do |key, meta|
        next if meta[:ignore]
        begin
          value = data[key]
          value = data[meta[:scope]] if meta.has_key? :scope
          value = value[meta[:inner_scope]] if meta.has_key? :inner_scope
          value = value.send(meta[:filter]) if meta.has_key? :filter
          if self.class.associations.has_key? key
            value = self.send(self.class.associations[key]).send(key)
          end
          if meta[:type] == Integer
            value = value.to_i
          elsif meta.has_key? :type && meta[:type] != Hash
            value = meta[:type].new(value)
          end
        rescue NameError => ex
          raise ex
          value = nil
        end
        instance_variable_set("@#{key.to_s}", value)
        self.attributes[key] = value
      end
    end

    def self.find(id)
      resp = conn.get do |req|
        req.url [
          "#{Codewars::BaseObject::BASE_API}",
          "#{replace_identifiers(@resource_name, {id: id})}"
        ].join('/')
      end

      raise Codewars::NotFound.new(self, id) if resp.status == 404
      self.new(parse_response(resp))
    end

    protected
    def self.parse_response(response)
      parsed_response = JSON.parse(response.body, symbolize_names: true)
      new_keys = {}
      parsed_response.each do |key, val|
        if key =~ /[A-Z]/
          new_key = key.to_s.chars.map{ |c| c == c.upcase ? "_#{c.downcase}" : "#{c}"}.join('')
          new_keys[new_key.to_sym] = key
        end
      end
      new_keys.each do |new_key, old_key|
        parsed_response[new_key] = parsed_response.delete(old_key)
      end
      parsed_response
    end

    def self.replace_identifiers(resource_name, identifiers)
      resource_name.split('/').map { |path| identifiers.fetch(path[1..-1].to_sym, path) }.join('/')
    end

    def self.conn
      @conn ||= Faraday.new(:url => 'https://www.codewars.com/', headers: {'Authorization' => 'zB4zC6zAFW1gXy6VWUxo'})
    end

    def self.get_deffered_response(dmid)
      loop do
        resp = self.conn.get do |req|
          req.url "#{Codewars::BaseObject::BASE_API}/deferred/#{dmid}"
        end
        parsed_reponse = parse_response(resp)
        return parsed_reponse if parsed_reponse[:success]
        sleep 1
      end
    end

    def self.attribute(attribute_name, type: nil, scope: nil, inner_scope: nil, filter: nil, ignore: false)
      self.attributes[attribute_name] = {}
      self.attributes[attribute_name][:scope] = scope unless scope.nil?
      self.attributes[attribute_name][:inner_scope] = inner_scope unless inner_scope.nil?
      self.attributes[attribute_name][:filter] = filter unless filter.nil?
      self.attributes[attribute_name][:type] = type unless type.nil?
      self.attributes[attribute_name][:ignore] = ignore if ignore

      unless self.respond_to?(attribute_name)
        define_method attribute_name do
          self.attributes[attribute_name]
        end
      end

      unless self.respond_to?(:"#{attribute_name}=")
        define_method :"#{attribute_name.to_s}=" do |val|
          self.attributes[attribute_name] = val
        end
      end
    end

    def self.associate(association, attribute)
      self.attribute(attribute)
      self.associations[attribute.to_sym] = association
    end

    def self.resource_name(resource)
      @resource_name = resource
    end

    def self.attributes
      return @attributes unless @attributes.nil?
      @attributes = {}
      @attributes = superclass.attributes.merge(@attributes) if superclass < Codewars::BaseObject
      @attributes
    end

    def self.associations
      @associations ||= {}
      return @associations unless @associations.nil?
      @associations = {}
      @association = superclass.associations.merge(@associations) if superclass < Codewars::BaseObject
      @associations
    end

    def attributes
      @attributes ||= {}
      @attributes
    end

    def to_s
      attributes.map do |key, value|
        begin
          if self.class.associations.has_key? key.to_sym
            value = self.send(self.class.associations[key.to_sym]).send(key.to_sym)
          end
          value = self.send(key.to_sym) if value.nil?
        rescue NameError
          value = nil
        end
        human_key = key.to_s.split("_").map{|k|"#{k[0].upcase}#{k[1..-1]}"}.join(' ')
        "#{human_key}: #{value}"
      end.join("\n")
    end
  end
end
