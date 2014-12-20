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
