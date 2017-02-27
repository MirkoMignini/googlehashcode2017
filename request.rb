class Request
  attr_accessor :input, :size, :video, :endpoint, :cached, :processed

  def initialize(input, line)
    @input = input
    @video, @endpoint, @size = line.split(' ').map(&:to_i)
    @video = input.videos[@video]
    @endpoint = input.endpoints[@endpoint]
    @cached = false
    @processed = false
  end

  def best_score
    cache_latency = endpoint.get_best_cache_latency(video)
    saving = cache_latency > 0 ? endpoint.latency - cache_latency : 0
    size * saving
  end

  def get_latency_saving
    #return 0 unless cached
    endpoint.latency - endpoint.get_best_video_latency(video)
  end

  def self.sort_by_something(requests)
    requests.select { |v| v.processed == false }.sort_by { |v| -v.best_score }
  end
end
