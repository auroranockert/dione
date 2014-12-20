require 'time'

module Dione
  class Date < Dione::Object
    type 'dione/date'

    def as_time
      Time.iso8601(self.document['date'])
    end

    def to_template
      self.as_time
    end
  end
end