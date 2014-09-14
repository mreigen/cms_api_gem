require_relative "./base_object"

class Tenant < BaseObject
  class << self
    def create(params)
      BaseObject.create(params.merge(subject: "tenants"))
    end

    def create_many(*hashes)
      hashes.each { |hash|
        BaseObject.create(hash.merge({subject: "tenants"}))
      }
    end

    # tenants are deleted by Mongo object id in CMS app
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
        tenants = Tenant.find(title: title)
        tenants.each {|t|
          Tenant.delete(id: Tenant.parse_id(t))
        } unless tenants.empty?
      end
    end

    def parse_id(tenant_hsh)
      tenant_hsh[:_id][:$oid] if tenant_hsh && tenant_hsh[:_id]
    end
  end
end