# frozen_string_literal: true

require "net/http"
require "uri"

class GetDataFromApi

  def self.data(url, preferred_locale)
    uri = URI(url + "/api/v1/data?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.contributions(url, preferred_locale)
    uri = URI(url + "/api/v1/data/contributions?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.containers(url, preferred_locale)
    uri = URI(url + "/api/v1/data/containers?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.authors(url, preferred_locale)
    uri = URI(url + "/api/v1/data/authors?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.contribution(url, ref, preferred_locale)
    ref = CGI.escape(ref)
    uri = URI(url + "/api/v1/data/contributions/#{ref}?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.container(url, ref, preferred_locale)
    ref = CGI.escape(ref)
    uri = URI(url + "/api/v1/data/containers/#{ref}?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end

  def self.author(url, ref, preferred_locale)
    ref = CGI.escape(ref)
    uri = URI(url + "/api/v1/data/authors/#{ref}?preferred_locale=#{preferred_locale}")
    begin
      result = Net::HTTP.get(uri)
      JSON.parse(result)
    rescue StandardError
      nil
    end
  end
end
