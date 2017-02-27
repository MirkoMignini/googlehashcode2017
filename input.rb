require_relative './cache'
require_relative './endpoint'
require_relative './video'
require_relative './request'
require 'benchmark'

class Input
  attr_accessor :videos, :endpoints, :requests, :caches, :cache_size

  def read_file(file_name)
    File.open(file_name, 'r') do |file|
      read_header(file.readline)
      read_videos(file.readline)
      read_endpoints(file)
      read_requests(file)
    end
  end

  def read_header(line)
    @videos, @endpoints, @requests, @caches, @cache_size = line.split(' ').map(&:to_i)
    @caches = Array.new(@caches){ |i| Cache.new(i, self, cache_size) }
  end

  def read_videos(line)
    @videos = Array.new(@videos)
    line.split(' ').map(&:to_i).each_with_index do |size, index|
      @videos[index] = Video.new(index, self, size)
    end
  end

  def read_endpoints(file)
    @endpoints = Array.new(@endpoints)
    @endpoints.count.times do |i|
      @endpoints[i] = Endpoint.new(i, self, file)
    end
  end

  def read_requests(file)
    @requests = Array.new(@requests)
    @requests.count.times do |i|
      @requests[i] = Request.new(self, file.readline)
    end
  end

  def benchmark
    puts Benchmark.measure { Request.sort_by_size(@requests) }
  end

  # def process
  #   loop do
  #     found = false
  #     count = 0
  #     sorted = Request.sort_by_size(@requests)
  #     puts "Requests: #{sorted.count}"
  #     sorted.each_with_index do |request, index|
  #       #puts "#{index}"
  #       request.processed = true
  #       if request.endpoint.add_video(request.video)
  #         request.cached = true
  #         found = true
  #         count += 1
  #         #break if count == 1000
  #       end
  #     end
  #     break unless found
  #   end
  # end

  def process
    count = 0
    requests = @requests
    loop do
      requests = Request.sort_by_something(requests)
      request = requests.first
      break if request.nil?
      request.processed = true
      if request.endpoint.add_video(request.video)
        #request.cached = true
        puts "Requests #{count} cached"
      else
        puts "Requests #{count} NOT cached"
      end
      count += 1
    end
  end

  def write_file(file_name)
    File.open(file_name, 'w') do |file|
      file.write("#{caches.count}\n")
      caches.each do |cache|
        file.write("#{cache.index} #{cache.videos.map(&:index).join(' ')}\n")
      end
    end
  end

  def calc_score
    saving = 0.0
    size = @requests.map(&:size).reduce(&:+)
    @requests.select{|v| v.processed}.each do |request|
      saving += request.get_latency_saving * request.size
    end
    saving / size * 1000.0
  end

  def debug_endpoints
    @endpoints.map(&:debug)
  end

  def debug_caches
    @caches.map(&:debug)
  end
end

input = Input.new
input.read_file(ARGV[0])
#input.benchmark
input.process
#input.debug_endpoints
#input.debug_caches
input.write_file(ARGV[0].gsub('.in', '.out'))
puts "SCORE: #{input.calc_score.to_i}"
