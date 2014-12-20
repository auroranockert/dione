module Dione
  class Attachment
    def initialize(object, name)
      @object, @name = object, name
    end

    def metadata
      @metadata ||= @object.document['attachments'][@name].merge(@object.document['_attachments'][@name])
    end

    def data
      @object.site.database.fetch_attachment(@object.document, @name)
    end

    def content_type
      self.metadata['content_type']
    end
  end
end
