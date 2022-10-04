module InOtherThread
  def in_other_thread(&block)
    thread = Thread.new(&block)
    thread.value
  end
end
