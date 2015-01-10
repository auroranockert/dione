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
  class Object
    attr_reader :database, :document, :parent

    def self.type(name)
      Dione::Database.register_type(name, self)
    end

    def initialize(database, document, parent = nil)
      @database, @document, @parent = database, document, parent
    end

    def root
      unless @root
        parent = self.parent

        @root = parent ? parent.root : self
      end

      @root
    end

    def id
      id = self['_id']

      [id] if id
    end

    def [](key)
      self.document[key]
    end

    def call(env)
      http_method = "http_#{env['REQUEST_METHOD'].downcase}"

      if self.respond_to? http_method
        self.send(http_method, env)
      else
        methods = [:get, :head, :post, :put, :delete].map do |method|
          method.to_s.upcase if self.respond_to? "http_#{method}"
        end.compact.join(', ')

        [405, { 'Allow' => methods }, []]
      end
    end

    def key
      self['_key']
    end

    def attachment(name)
      root = self.root
      attachments = root['_attachments']

      available = attachments && attachments[name]

      Dione::Attachment.new(root, name) if available
    end

    def attachments
      root = self.root

      (root['_attachments'] || {}).keys.map do |name|
        Dione::Attachment.new(root, name)
      end
    end
  end
end
