require File.join(File.expand_path(File.dirname(__FILE__)), "require_farm")

app = Qt::Application.new(ARGV)

manager = Manager.new

app.exec