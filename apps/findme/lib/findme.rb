require 'pathname'

T_ROOT = File.join(File.dirname(Pathname.new(__FILE__).realpath),'/../../../lib')

require T_ROOT + "/carto.rb"

module Findme
  class << self
    def search_floor(number, matric)
      machines, threads = [], []

      Inventory.find_by_floor(number).each do |machine|
        threads << Thread.new do
          users = `ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ConnectTimeout=1 #{machine} users 2> /dev/null`
          machines.push(machine) if users =~ Regexp.new(matric)
        end
      end

      threads.each { |thread| thread.join }
      
      machines
    end
    
    def search_all_floors(matric)
      ("3".."8").map { |number| search_floor(number, matric) }.flatten
    end
  end
end