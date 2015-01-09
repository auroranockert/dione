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
  class Object
    attr_reader :database, :document, :parent

    def self.type(name)
      Dione::Database.register_type(name, self)
    end

    def initialize(database, document, parent)
      @database, @document, @parent = database, document, parent
    end

    def root
      @root ||= self.parent ? self.parent.root : self
    end

    def id
      [self['_id']] if self['_id']
    end

    def [](key)
      self.document[key]
    end

    def call(env)
      method = "http_#{env['REQUEST_METHOD'].downcase}"
      
      if self.respond_to? method
        self.send(method, env)
      else
        methods = [:get, :head, :post, :put, :delete].map do |method|
          method.to_s.upcase if self.respond_to? "http_#{method}".intern
        end.compact.join(', ')

        [405, { 'Allow' => methods }, StringIO.new('')]
      end
    end

    def key
      self['_key']
    end

    def attachment(name)
      if attachments = self.root['_attachments'] and attachments.keys.include? name
        Dione::Attachment.new(self.root, name)
      else
        nil
      end
    end

    def attachments
      if attachments = self.root['_attachments']
        attachments.keys.map { |name| Dione::Attachment.new(self.root, name) }
      else
        []
      end
    end
  end
end
