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
