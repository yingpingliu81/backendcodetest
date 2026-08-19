module Loader
  def load
    raise NotImplementedError, "#{self.class} must implement #load"
  end
end