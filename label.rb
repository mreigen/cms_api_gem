require_relative "./base_object"

class Label < BaseObject
  class << self
    def create(params)
      BaseObject.create(params.merge(subject: "labels"))
    end

    def create_many(*hashes)
      hashes.each { |hash|
        BaseObject.create(hash.merge({subject: "labels"}))
      }
    end

    # labels are deleted by Mongo object id in CMS app
    # if that is changed, change it here too
    def delete(params)
      _params = params.clone
      id = _params.delete(:id)
      return unless id
      send_request({method: :delete, subject: subject, id: id}.merge(_params))
    end

    def delete_many(*titles)
      return unless titles
      titles.each do |title|
        labels = Label.find(title: title)
        labels.each {|l|
          Label.delete(id: Label.parse_id(l))
        } unless titles.empty?
      end
    end

    def parse_id(label_hsh)
      label_hsh[:_id][:$oid] if label_hsh && label_hsh[:_id]
    end
  end
end