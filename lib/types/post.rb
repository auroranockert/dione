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
  class Post < Dione::Object
    type 'dione/post'

    def title
      self['title']
    end

    def published_at
      Time.iso8601(self['published_at']) if self['published_at']
    end

    def urls
      self['urls']
    end

    def canonical_url
      self['canonical_url'] || self.urls.first
    end

    def content
      @content ||= self.site.reify(self['content'], self)
    end

    def template
      self.site.reify(self['template'])
    end

    def to_template
      {
        'title' => self.title,
        'published_at' => self.published_at,
        'urls' => self.urls,
        'canonical_url' => self.canonical_url
      }
    end

    def http_get(env)
      document = { 'page' => self.to_template, 'site' => self.site.to_template }
      document['content'] = self.content.render(env, document)

      [200, { 'Content-Type' => 'text/html' }, StringIO.new(self.template.render(env, document))]
    end
  end
end
