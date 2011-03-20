require 'lib/rdirbrowser.rb'

Rdirbrowser.cgiinit

Rdirbrowser.loadconfig

Rdirbrowser.htmlheader

if $cgi['module'] == "upload"
	Rdirbrowser.uploadpage
elsif $cgi['module'] == "destroyer"
	Rdirbrowser.destroyer
elsif $cgi['module'] == "uploader"
	Rdirbrowser.uploader
else
	Rdirbrowser.renderlist
end

Rdirbrowser.htmlfooter
