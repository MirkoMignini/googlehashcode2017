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

  def self.sort_by_size(requests)
    # endpoints.sort_by { |v| [v.endpoint.latency, v.size] }.reverse
    # endpoints.sort_by { |v| [-v.video.size, v.size] }.reverse
    requests.select { |v| v.processed == false }.sort_by { |v|
      #v.size * (v.endpoint.latency - v.endpoint.get_saving(v.video, force))
      #v.size * v.endpoint.latency
      -v.best_score
    }#.reverse
  end
end
