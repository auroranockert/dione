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

module Dione
  DECODE_NAME_TO_CLASS = {}
  DECODE_CLASS_TO_NAME = {}

  class Object
    attr_reader :site, :document

    def self.find(site, id)
      self.reify(site, { 'id' => id })
    end

    def self.reify(site, document, parent = nil)
      if name = document['id']
        self.new(site, site.database.get(name).merge(document))
      else
        document = document.merge('_id' => parent.document['_id'], '_rev' => parent.document['_rev'], '_attachments' => parent.document['_attachments']) if parent
        self.new(site, document)
      end
    end

    def self.type(name)
      DECODE_NAME_TO_CLASS[name] = self
      DECODE_CLASS_TO_NAME[self] = name
    end

    def initialize(site, document)
      @site, @document = site, document
    end

    def attachment(name)
      Dione::Attachment.new(self, name) if self.document['_attachments'].keys.include? name
    end

    def attachments
      self.document['_attachments'].keys.map { |name| Dione::Attachment.new(self, name) }
    end
  end
end
