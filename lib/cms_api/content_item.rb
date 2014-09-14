require_relative "./base_object"

class ContentItem < BaseObject
  class << self
    # custom runr actions
    def exec_runr_task(params)
      send_request_and_parse_response(params)
    end

    def delete_many(*titles)
      return unless titles
      titles.each do |title|
        content_type = self.name.underscore
        if content_type == "content_item"
          content_items = ContentItem.find(title: title)
        else
          content_items = ContentItem.find(title: title, content_type: content_type)
        end
        content_items.each {|i|
          ContentItem.delete(guid: ContentItem.parse_id(i))
        } unless content_items.empty?
      end
    end

    # required:
    # content_item guid
    # tenants_to_add

    # Adds tenants to a content item
    # @param params [Hash] the param hash
    # (+:guid+, +:tenants_to_add+ keys are required)
    # @return [Hash] the resulting content item
    def add_tenants(params)
      exec_runr_task(params.merge(method: :post, task: "add_tenants"))
    end

    # Removes tenants from a content item
    # @param params [Hash] the param hash
    # (+:guid+, +:tenants_to_remove+ keys are required)
    # @return [Hash] the resulting content item
    def remove_tenants(params)
      exec_runr_task(params.merge(method: :delete, task: "remove_tenants"))
    end

    # Removes labels from a content item
    # @param params [Hash] the param hash
    # (+:guid+, +:labels+ keys are required)
    # @return [Hash] the resulting content item
    def add_labels(params)
      exec_runr_task(params.merge(method: :post, task: "add_labels"))
    end

    # Removes labels from a content item
    # @param params [Hash] the param hash
    # (+:guid+, +:labels+ keys are required)
    # @return [Hash] the resulting content item
    def remove_labels(params)
      exec_runr_task(params.merge(method: :delete, task: "remove_labels"))
    end

    def parse_id(content_item_hsh)
      content_item_hsh[:guid] if content_item_hsh && content_item_hsh[:guid]
    end

  end
end

class Document < ContentItem
  class << self
    def create(params)
      ContentItem.create(params.merge(subject: "documents"))
    end
  end
end

class Video < ContentItem
  class << self
    def create(params)
      ContentItem.create(params.merge(subject: "videos"))
    end
  end
end

class Track < ContentItem
  class << self
    def create(params)
      ContentItem.create(params.merge(subject: "tracks"))
    end
  end
end

class Image < ContentItem
  class << self
    def create(params)
      ContentItem.create(params.merge(subject: "images"))
    end
  end
end
