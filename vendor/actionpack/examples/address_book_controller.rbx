#!/usr/bin/env ruby

require "address_book_controller"
AddressBookController.process_cgi(CGI.new)