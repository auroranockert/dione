# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the "Licence"); You
# may not use this work except in compliance with the Licence. You may obtain a
# copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# Licence for the specific language governing permissions and limitations under
# the Licence.

require 'couchrest'

module Dione
  class Database
    TYPE_TO_CLASS = {}

    def self.register_type(name, klass)
      TYPE_TO_CLASS[name] = klass
    end

    def initialize(url)
      @database = CouchRest.database(url)
    end

    def view(design, view, params = {})
      params.merge!(include_docs: true) if params[:reify]

      result = @database.view("#{design}/#{view}", params)

      if params[:reify]
        result['rows'].map { |r| self.reify(r['doc']) }
      else
        result
      end
    end

    def fetch_attachment(object, name)
      @database.fetch_attachment(object.document, name)
    end

    def reify(document, parent = nil)
      if !parent && document['id']
        document = @database.get(document['id']).merge(document)
      end

      type = TYPE_TO_CLASS[document['type']]

      type.new(self, document, parent) if type
    end

    def inspect
      "#<#{self.class.name}:#{self.object_id} @url=#{@database}>"
    end
  end
end
