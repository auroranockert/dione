# Copyright 2014 Jens Nockert
#
# Licensed under the EUPL, Version 1.1 or – as soon they will be approved by
# the European Commission - subsequent versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the Licence.
# You may obtain a copy of the Licence at: https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Licence for the specific language governing permissions and
# limitations under the Licence. 

require 'couchrest'

module Dione
  class Site
    attr_reader :database

    def initialize(database)
      @database = CouchRest.database(database)
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