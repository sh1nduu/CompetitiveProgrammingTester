#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require 'fileutils'
require 'net/http'
require 'uri'

INTERVAL = 2 # crawling interval seconds

class TestCase
  attr_reader :data

  def initialize(problem_id, index)
    @problem_id = problem_id
    @index = index
    @type = "in"
    @data = {}
  end

  def switch
    @type = @type == "in" ? "out" : "in"
  end

  def increment
    @index += 1
  end

  def description
    "#{@problem_id}/#{@index}/#{@type} URL: #{url_string}"
  end

  def fetch
    response = Net::HTTP.get_response(uri)
    sleep(INTERVAL)

    raise "HTTP Error #{response.code}" if response.code != "200"
    raise "Not available" if unavailable?(@index, @problem_id, response.body)
    @body = response.body
    store_body
  end

  private
  def uri
    URI.parse(url_string)
  end

  def url_string
    testcase_url = "https://judgedat.u-aizu.ac.jp/testcases/"
    "#{testcase_url}#{@problem_id}/#{@index}/#{@type}"
  end

  def store_body
    key = @type == "in" ? "input" : "expect"
    @data[key] = @body
  end

  def unavailable?(index, problem_id, text)
    text == unavailable_text(index, problem_id)
  end

  def unavailable_text(index, problem_id)
    "/* Test case ##{index} for problem #{problem_id} is not available. */"
  end
end

class YamlFile
  def initialize(data, problem_id)
    @data = data
    @problem_id = problem_id
  end

  def write
    create_dir

    File.open("#{save_path}testcase.yml", "w+") do |f|
      f.write(@data)
    end
  end

  private
  def create_dir
    FileUtils.mkdir_p(save_path) unless FileTest.exist?(save_path)
  end

  def save_path
    "./#{@problem_id}/"
  end
end

def main
  params = ARGV.getopts('i:')

  problem_id = params["i"]
  raise "specify problem_id. use -i" unless problem_id

  index = 1
  testcase = TestCase.new(problem_id, index)
  yaml = {"testcase" => []}

  begin
    while true do
      testcase.fetch
      puts "Loaded: #{testcase.description}"
      testcase.switch

      testcase.fetch
      puts "Loaded: #{testcase.description}"
      yaml["testcase"] << testcase.data.dup
      testcase.increment
      testcase.switch
    end
  rescue RuntimeError
    puts "Available testcases are loaded."
  ensure
    YamlFile.new(yaml.to_yaml, problem_id).write
    puts "Finished writing a file."
  end
end

main
