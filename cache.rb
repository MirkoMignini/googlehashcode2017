class Cache
  attr_accessor :index, :size, :latency, :used, :videos, :full

  def initialize(index, input, size)
    @index = index
    @input = input
    @size = size
    @used = 0
    @videos = Array.new
    @full = false
  end

  def add_video(video)
    return false if (@used + video.size > size)
    @videos << video
    @used += video.size
    #@full = @used == @size
    true
  end

  def can_add?(video)
    @used + video.size <= size
  end

  def include?(video)
    @videos.include?(video)
  end

  def debug
    puts "cache #{index} - latency: #{latency} - used: #{used}"
  end
end
