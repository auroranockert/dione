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

module Dione
  class Attachment
    attr_reader :name

    def initialize(object, name)
      @document = object['_attachments'][name]

      if attachments = object['attachments']
        @document = (attachments[name] || {}).merge(@document)
      end

      @database, @name, @object = object.database, name, object
    end

    def id
      [self.object['_id'], self.name]
    end

    def [](key)
      @document[key]
    end

    def content
      @database.fetch_attachment(@object, self.name)
    end

    def content_length
      self['length']
    end

    def content_type
      self['content_type']
    end

    def call(env)
      headers =  {
        'Content-Type' => self.content_type,
        'Content-Length' => self.content_length.to_s
      }

      case env['REQUEST_METHOD']
      when 'GET' then [200, headers, [self.content]]
      when 'HEAD' then [200, headers, []]
      else
        [405, { 'Allow' => methods }, []]
      end
    end
  end
end
