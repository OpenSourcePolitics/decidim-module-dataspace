# frozen_string_literal: true

require "net/http"
require "uri"

class GetDataFromApi

  def self.data(url)
    uri = URI(url + "/api/v1/data")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.contributions(url)
    uri = URI(url + "/api/v1/data/contributions")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.containers(url)
    uri = URI(url + "/api/v1/data/containers")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.authors(url)
    uri = URI(url + "/api/v1/data/authors")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.contribution(url, ref)
    uri = URI(url + "/api/v1/data/contributions/#{ref}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.container(url, ref)
    uri = URI(url + "/api/v1/data/containers/#{ref}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.author(url, ref)
    uri = URI(url + "/api/v1/data/authors/#{ref}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end
end
