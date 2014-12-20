module Dione
  class Middleware
    MIDDLEWARE = []
    
    def self.priority(priority)
      MIDDLEWARE.push([self, priority])
    end

    def self.all
      MIDDLEWARE.sort { |a, b| a[1] <=> b[1] }.map(&:first)
    end
  end
end