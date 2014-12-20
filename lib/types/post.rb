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
      self.document['title']
    end

    def content
      @content ||= self.site.reify(self.document['content'], self)
    end

    def published_at
      self.site.reify(self.document['published_at']) if self.document['published_at']
    end

    def safe_proxy
      PostProxy.new(self)
    end

    def template
      self.site.reify(self.document['template'])
    end

    def call(env)
      [200, { 'Content-Type' => 'text/html' }, StringIO.new(self.template.render(env, 'content' => self.content.to_template, 'page' => self.to_template, 'site' => self.site.to_template))]
    end

    def to_template
      { 'title' => self.title, 'published_at' => self.published_at.to_template }
    end
  end
end
