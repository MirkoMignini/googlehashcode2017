class Video
  attr_accessor :size, :input, :index

  def initialize(index, input, size)
    @index = index
    @input = input
    @size = size
  end
end
