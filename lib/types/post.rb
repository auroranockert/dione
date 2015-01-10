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
  class Post < Dione::Object
    type 'dione/post'

    def title
      self['title']
    end

    def published_at
      Time.iso8601(self['published_at']) if self['published_at']
    end

    def urls
      self['routes']
    end

    def canonical_url
      self['canonical_url'] || self.urls.first
    end

    def content
      @content ||= Dione::Content.new(self.database, self['content'], self)
    end

    def template
      self.database.reify(self['template'])
    end

    def to_liquid
      {
        'title' => self.title,
        'published_at' => self.published_at,
        'urls' => self.urls,
        'canonical_url' => self.canonical_url
      }
    end

    def http_get(env)
      document = { 'page' => self, 'site' => env[:dione][:site] }

      document['content'] = self.content.render(env, document)

      headers = { 'Content-Type' => 'text/html' }

      [200, headers, [self.template.render(env, document)]]
    end

    def http_head(env)
      self.http_get(env).tap do |reply|
        reply[2] = []
      end
    end
  end
end
