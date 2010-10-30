require 'net/http'
require 'rexml/document'
include REXML

class HostManager
    PROFILENAME = File.dirname(__FILE__) + "/../../hosts/inventory.xml"

    def self.get_inventory
        unless FileTest.exist?(PROFILENAME) and File.mtime(PROFILENAME) > (Time.now - 86400)
            Net::HTTP.start("lcfg.inf.ed.ac.uk") { |http|
                resp = http.get("/profiles/inf.ed.ac.uk/inventory/XMLInventory/profile.xml")
                open(PROFILENAME, "w") { |file|
                    file.write(resp.body)
                }
            }
        end
        return Document.new(File.new(PROFILENAME))
    end

    def self.inventory
        @inventory ||= get_inventory
    end

    def self.lookup_lab(hostname)
        lab = inventory.root.elements["node[@name='" + hostname + "']/location/text()"].to_s()
        if lab.empty? then
            return nil
        else
            return lab
        end
    end

    def self.lookup_floor(hostname)
        matchdata = /^(.+)\.(.+)$/.match(lookup_lab(hostname))
        if matchdata then
            return matchdata[1]
        else
            return nil
        end
    end

    def self.get_hosts_floor(floor)
        hostattrs = inventory.root.each_element("node[starts-with(location/text(),'"+floor+".')]/@name")
        return hostattrs.map { |hostattr| hostattr.to_s() }
    end

    def self.get_hosts_lab(floor, lab)
        floor_lab = floor + "." + lab
        hostattrs = inventory.root.each_element("node[location='"+floor_lab+"']/@name")
        return hostattrs.map { |hostattr| hostattr.to_s() }
    end
end