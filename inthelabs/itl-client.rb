#!/usr/bin/env ruby

require 'socket'
require 'pathname'
require 'gtk2'

APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath)
ID_PATH = ENV['HOME'] + '/.config/itl-userid'

begin
	@id_file = File.open("#{ID_PATH}", 'r+')
rescue
	@id_file = File.open("#{ID_PATH}", 'w+')
end

@server = 'localhost'
@port = 54415
@details ||= IO.readlines(ID_PATH)

if @details[0].nil?
	@id = nil
	@user = nil
	@location = nil
else
	@id = @details[0].chomp
	@user = @details[1].chomp
	@location = @details[2].chomp
end

@online = true

def send(string)
	link = TCPSocket.open(@server, @port)
	link.puts(string)
	link.close
end

### WINDOW INIT

window = Gtk::Window.new
window.set_default_size(300,150)
window.signal_connect("delete_event") {
	window.hide_all
}

table1 = Gtk::Table.new(4,2,true)

### TRAY INIT
tray=Gtk::StatusIcon.new
tray.stock=Gtk::Stock::HELP

tray.tooltip="inthelabs"

tray.signal_connect('activate'){
	if @online
		send("remove,#{@id},#{@user}")
		@online = false
	else
		send("logon,#{@id}")
		@online = true
	end
}

traysearch = Gtk::ImageMenuItem.new(label="Search",use_underline=false)
traysearch.signal_connect('activate'){
	warning = Gtk::Dialog.new("O RLY?",
							$main_application_window,
                            Gtk::Dialog::MODAL,
                            [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT ],
                            [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT ])
    warning.vbox.add(Gtk::Label.new("This will open a new browser window.\n Is that okay?"))
    warning.show_all
    
    warning.run do |reply|
    	case reply
    		when Gtk::Dialog::RESPONSE_ACCEPT
				`gnome-open http://#{@server}:3000`
		end
		warning.destroy
	end
}

traywindow = Gtk::ImageMenuItem.new(label="Show window",use_underline=false)
traywindow.signal_connect('activate'){ window.show_all }

trayquit = Gtk::ImageMenuItem.new(label="Quit",use_underline=false)
trayquit.signal_connect('activate'){ Gtk.main_quit }

traymenu = Gtk::Menu.new
traymenu.append(traysearch)
traymenu.append(traywindow)
traymenu.append(Gtk::SeparatorMenuItem.new)
traymenu.append(trayquit)
traymenu.show_all

tray.signal_connect('popup-menu'){|tray, button, time| traymenu.popup(nil,nil,button,time)}

## get username and location
def get_user_info(update)
    dialog = Gtk::Dialog.new("User Info",
                             $main_application_window,
                             Gtk::Dialog::MODAL,
                             [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT ],
                             [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT ])
    dialog.set_default_size(300,100)
    dialog.set_default_response(Gtk::Dialog::RESPONSE_ACCEPT)
    
    userbox = Gtk::Entry.new
    userbox.max_length=13
    if update
    	userbox.text = "#{@user}"
    else
    	userbox.text = ENV['USER']
    	userbox.select_region(0,-1)
    end
    

    userboxlbl = Gtk::Label.new("Username: ")
    locboxlbl = Gtk::Label.new("Location: ")
    
    locbox = Gtk::Entry.new
    locbox.max_length=30
   	if update
   		locbox.text = "#{@location}"
   		locbox.select_region(0,-1)
   	else
    	locbox.text = "eg: at5, west lab"
    end
    
    tableholder = Gtk::Table.new(2,3,true)
    
    tableholder.attach(userboxlbl,0,1,0,1)
    tableholder.attach(userbox,1,3,0,1)
    tableholder.attach(locboxlbl,0,1,1,2)
    tableholder.attach(locbox,1,3,1,2)
    
    dialog.vbox.add(tableholder)
    
    dialog.show_all
    
    dialog.run do |reply|
    	case reply
    		when Gtk::Dialog::RESPONSE_ACCEPT
    			@user = userbox.text
				@location = locbox.text
				link = TCPSocket.open(@server, @port)
				if update
					link.puts("update,#{@id},#{@user},#{@location}")					
				else
					link.puts("add,#{@user},#{@location}")
					@id = link.gets
				end
				link.close
				@id_file = File.open("#{ID_PATH}", 'w')
				@id_file.puts @id
				@id_file.puts @user
				@id_file.puts @location
				@id_file.close
			when Gtk::Dialog::RESPONSE_REJECT
				if not update
					exit()
				end
    	end
    	dialog.destroy
    end
end

## update
updatebutton = Gtk::Button.new("Update User Info")
updatebutton.signal_connect("clicked") {
	get_user_info(true)
	@infolabel.set_text("You are #{@user} in #{@location}")
}

## search
searchbutton = Gtk::Button.new("See Who's Online")
searchbutton.signal_connect("clicked") {
	warning = Gtk::Dialog.new("O RLY?",
							$main_application_window,
                            Gtk::Dialog::MODAL,
                            [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT ],
                            [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT ])
    warning.vbox.add(Gtk::Label.new("This will open a new browser window.\n Is that okay?"))
    warning.show_all
    
    warning.run do |reply|
    	case reply
    		when Gtk::Dialog::RESPONSE_ACCEPT
				`gnome-open http://#{@server}:3000`
		end
		warning.destroy
	end
}

## quit
exitbutton = Gtk::Button.new("Quit")
exitbutton.signal_connect("clicked") {
	send("remove,#{@id},#{@user}")
	Gtk.main_quit
}

## attach and start
window.border_width = 5
window.add(table1)

table1.attach(updatebutton, 0,2,1,2, nil, nil, 0, 0)
table1.attach(searchbutton, 0,2,2,3, nil, nil, 0, 0)
table1.attach(exitbutton, 0,2,3,4, nil, nil, 0, 0)

if @user.nil?
	get_user_info(false)
else
	@id_file = File.open("#{ID_PATH}", 'w')
	@id_file.puts @id
	@id_file.puts @user
	@id_file.puts @location
	@id_file.close
	send("logon,#{@id}")
end

# link = TCPSocket.open(@server, @port)

@infolabel = Gtk::Label.new("You are #{@user} in #{@location}")
table1.attach(@infolabel, 0,2, 0,1, nil, nil, 0,0)

window.show_all

Gtk.main
