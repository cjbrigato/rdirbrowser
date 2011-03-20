require 'lib/rdirbrowser.rb'

Rdirbrowser.cgiinit

Rdirbrowser.loadconfig

Rdirbrowser.htmlheader

if $params.has_key?"file"
	file = $params["file"].first
	server_file = $basedir + file.original_filename
	File.open(server_file.untaint, "w") do |f|
		f << file.read
	end
end

type = Rdirbrowser.getmimetype($basedir+file.original_filename)
if type =~ /image\/(.*)/ or file =~ /(.*)jpg|(.*)jpeg|(.*)png/
	system("mv #{$basedir+file.original_filename} #{$basedir}/images")
	puts "<b>Image file detected.</b> Moved to /images<br/>"
else
	system("mv #{$basedir+file.original_filename} #{$basedir}/others")
	puts "<b>No filetype detected</b>. Moved to /others<br/>"
end

Rdirbrowser.htmlfooter
