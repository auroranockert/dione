require 'couchrest'

module Dione
  class Site
    attr_reader :database

    def initialize(database)
      @database = CouchRest.database(database)
    end

    def self.route(env)
      site = Site.new(ENV['DIONE_DATABASE'])
      routes = site.database.view('dione/routes', key: env['PATH_INFO'])["rows"].map { |x| x['value'] }
      
      fail Dione::NotFound, "Multiple routes found for path #{env['PATH_INFO']}" if routes.length > 1

      object = site.reify('id' => routes.first[0])

      if attachment = routes.first[1]
        object.attachment(attachment)
      else
        object
      end
    end

    def reify(document, parent = nil)
      document = self.database.get(document['id']).merge(document) if document['id']

      if type = DECODE_NAME_TO_CLASS[document['type']]
        type.reify(self, document, parent)
      else
        fail Dione::NotFound, "Could not reify #{document.inspect}"
      end
    end

    def to_template
      {}
    end
  end
end