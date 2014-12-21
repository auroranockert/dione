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
    attr_reader :site, :document

    def self.find(site, id)
      self.reify(site, { 'id' => id })
    end

    def self.reify(site, document, parent = nil)
      if name = document['id']
        self.new(site, site.database.get(name).merge(document))
      else
        document = document.merge('_id' => parent['_id'], '_rev' => parent['_rev'], '_attachments' => parent['_attachments']) if parent

        self.new(site, document)
      end
    end

    def self.type(name)
      Dione::TYPE_TO_CLASS[name] = self
    end

    def initialize(site, document)
      @site, @document = site, document
    end

    def [](key)
      self.document[key]
    end

    def call(env)
      case env['REQUEST_METHOD']
      when 'GET'
        self.http_get(env)
      when 'HEAD'
        self.http_head(env)
      when 'POST'
        self.http_post(env)
      when 'PUT'
        self.http_put(env)
      when 'DELETE'
        self.http_delete(env)
      else
        self.http_other(env)
      end
    rescue NoMethodError
      methods = [:get, :head, :post, :put, :delete].map do |method|
        method.to_s.upcase if self.respond_to? "http_#{method}".intern
      end.compact.join(', ')

      [405, { 'Allow' => methods }, StringIO.new('')]
    end

    def key
      self['_key']
    end

    def attachment(name)
      Dione::Attachment.new(self, name) if self['_attachments'].keys.include? name
    end

    def attachments
      self['_attachments'].keys.map { |name| Dione::Attachment.new(self, name) }
    end
  end
end
