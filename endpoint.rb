class Endpoint
  attr_accessor :input, :index, :latency, :connected_caches

  def initialize(index, input, file)
    @index = index
    @input = input

    @latency, caches = file.readline.split(' ').map(&:to_i)

    @connected_caches = Array.new
    caches.times do
      index, latency = file.readline.split(' ').map(&:to_i)
      @connected_caches << { cache: input.caches[index], latency: latency }
    end
  end

  def caches_by_latency
    @caches_by_latency ||= @connected_caches.sort_by { |v| v[:latency] }
  end

  def debug
    puts "endpoint #{index} - latency: #{latency} - #{connected_caches.count} caches"
    caches_by_latency.each do |cache|
      puts "  cache #{cache[:cache].index} latency #{cache[:latency]}"
    end
  end

  def get_best_cache_latency(video)
    caches_by_latency.each do |cc_cache|
      return 0 if cc_cache[:cache].include?(video)
      return cc_cache[:latency] if cc_cache[:cache].can_add?(video)
    end
    0
  end

  def add_video(video)
    caches_by_latency.each do |cc_cache|
      return false if cc_cache[:cache].include?(video)
      return true if cc_cache[:cache].add_video(video)
    end
    false
  end
end
