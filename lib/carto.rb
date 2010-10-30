require 'pathname'

APP_ROOT = File.join(File.dirname(Pathname.new(__FILE__).realpath),'../apps/carto')
LIB_ROOT = File.join(File.dirname(Pathname.new(__FILE__).realpath),'./')

require LIB_ROOT + 'carto/inventory'
