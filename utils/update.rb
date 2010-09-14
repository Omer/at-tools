#!/usr/bin/env ruby

# Updater for at-tools (www.github.com/lolsoft/at-tools)

AT_TOOLS_SRC = File.expand_path('~/.at-tools/')
AT_APPS_DIR = AT_TOOLS_SRC + '/apps'
AT_BIN_DIR = AT_TOOLS_SRC + '/bin'

def command(command, dir = '.')
    Dir.chdir(dir) do
        return `#{command}`.chomp
    end
end

def current_tools
  Dir.glob('../apps/*').map { |path| path.split('/').last }
end

def link app
  FileUtils.ln_s(AT_APPS_DIR + "/#{app}/bin/#{app}",
                 AT_TOOLS_BIN + "/#{app}")
end

old_tools = current_tools

puts 'Checking for changes and updating at-tools core and programs...'
command('git pull', AT_TOOLS_SRC)

new_tools = current_tools - old_tools

new_tools.each { |tool| link tool }
