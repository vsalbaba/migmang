# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rake'

desc "spusti test a zapise ho do nazev_testu.html"
task :otestuj do
	system "spec #{ENV['TEST']} -fh > #{ENV['TEST']}.html"
end
desc "vygeneruje dokumentaci do doc, vynecha testy"
task :dokumentace do
	system "rdoc --force-update --exclude spec"
end
