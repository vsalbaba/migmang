require 'rubygems'
require 'Qt4'
require 'observer'

this_file_path = File.dirname(__FILE__)
require File.join(File.expand_path(this_file_path), "constant_farm")
require File.join(File.expand_path(this_file_path), "enhancements/mig_mang_board_helper")
require File.join(File.expand_path(this_file_path), "enhancements/array_enhancements")
require File.join(File.expand_path(this_file_path), "enhancements/fixnum_enhancements")
require File.join(File.expand_path(this_file_path), "enhancements/move_enhancements")
require File.join(File.expand_path(this_file_path), "views/mig_mang_board")
require File.join(File.expand_path(this_file_path), "views/theme")
require File.join(File.expand_path(this_file_path), "models/board")
require File.join(File.expand_path(this_file_path), "models/rules")
require File.join(File.expand_path(this_file_path), "models/mig_mang_board")
require File.join(File.expand_path(this_file_path), "models/player/abstract_player")
require File.join(File.expand_path(this_file_path), "models/player/minimax_player")
require File.join(File.expand_path(this_file_path), "models/player/gui_player")
require File.join(File.expand_path(this_file_path), "models/historian")
require File.join(File.expand_path(this_file_path), "models/manager")
