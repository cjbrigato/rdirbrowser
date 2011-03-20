require 'cgi'
require 'yaml'

class Rdirbrowser

	def self.cgiinit
		$cgi = CGI.new
		puts $cgi.header
		#$cmodule = $cgi['module'].capitalize
		$params = $cgi.params
	end

	def self.loadconfig
		conffile = "config/rdirbrowser.conf"

        	if File::exists?(conffile)
                	conffd = File.open(conffile)
                	conf = YAML.load(conffd)
                	conffd.close
        	else

                	puts "No configuration file found, exiting..."
                	exit
        	end

        	$basedir=conf['basedir']
		$title=conf['title']
		$admindir=conf['admindir']
	end


	def self.getmimetype(file)
		mimetype = `file -ib #{file}`.gsub(/;(.*)/,"")
		return mimetype.to_s
	end

	def self.setdelete(file)
		crossicon = '<img src="'+$admindir+'/icons/cross.png" />'
		if $cgi['candestroy'] == "yes"
			puts '<a href="'+$admindir+'/'+$directory+'destroy/'+file+'">'+crossicon+'</a> '
		end
	end

	def self.destroyer
		filepath = $cgi['filepath']

		result=system("rm -v #{$basedir+filepath}")
		if result == true
			puts "<b>SUCCES</b> : /#{filepath} was deleted<br/>"
		else
			puts "<b>FATAL</b> : Can't remove /#{filepath}<br/>"
		end
		puts "<br/>"
	end

	def self.renderlist
		$directory = $cgi['dir']
		if $directory =~ /\.\./ or $directory =~ /^\/(.*)/
        		$directory = ""
		end
		unless $directory =~ /(.*)\/$/
        		$directory = ""
		end

		if $directory == ""
        		puts '<h2 class="alt">Listing of /</h2><hr>'
		else
        		if $cgi['candestroy'] == "yes"
                		puts '<h2 class="alt">Listing of '+$directory+' - <a href="'+$admindir+'/'+$directory.gsub(/\//,"")+'">Normal Mode</a></h2><hr>'
        		else
                		puts '<h2 class="alt">Listing of '+$directory+' - <a href="'+$admindir+'/'+$directory.gsub(/\//,"")+'/destroy">Delete Mode</a></h2><hr>'
        		end
		end
		$checkdir = $basedir+$directory
		self.listdir($checkdir)
	end

	def self.listdir(dir)
		basedir = dir
		Dir.chdir(basedir)
		files = Dir.glob("*")
		files.sort!

		imageicon = '<img src="'+$admindir+'/icons/image.png" />'
		foldericon = '<img src="'+$admindir+'/icons/folder.png" />'
		filmicon = '<img src="'+$admindir+'/icons/film.png" />'
		soundicon = '<img src="'+$admindir+'/icons/music.png" />'
		fonticon = '<img src="'+$admindir+'/icons/font.png" />'
		pdficon = '<img src="'+$admindir+'/icons/page_white_acrobat.png" />'
		archicon = '<img src="'+$admindir+'/icons/package_green.png" />'
		htmlicon = '<img src="'+$admindir+'/icons/page_white_world.png" />'
		notypeicon = '<img src="'+$admindir+'/icons/page_white.png" />'

		files.each do |file|
			unless file == "." or file == ".." or file == "admin" or file == "index.html"
				
				type = self.getmimetype(file)

				if type =~ /image\/(.*)/ or file =~ /(.*)jpg|(.*)jpeg|(.*)png/
					self.setdelete(file)
					puts imageicon + ' - <a href="/'+$directory + file +'" rel="shadowbox" title="'+file+'">' + file + '</a>'
					puts '<br />'
				elsif file =~ /(.*)gz|(.*)tar|(.*)zip/
					self.setdelete(file)
					puts archicon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif file =~ /(.*)mp3|(.*)wav|(.*)ogg/
					self.setdelete(file)
					puts soundicon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif file =~ /(.*)pdf/
					self.setdelete(file)
					puts pdficon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif file =~ /(.*)ttf/
					self.setdelete(file)
                                        puts fonticon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif file =~ /(.*)mpg|(.*)mpeg|(.*)avi|(.*)mkv|(.*)mov/
					self.setdelete(file)
					puts filmicon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif type =~ /text\/html/
					self.setdelete(file)
                                        puts htmlicon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				elsif type =~ /application\/x-directory/
					puts foldericon + ' - <a href="'+$admindir+'/'+$directory+ file +'">' + file + '</a><br />'
				else
					self.setdelete(file)
					puts notypeicon + ' - <a href="/'+$directory + file +'">' + file + '</a>'
                                        puts '<br />'
				end
			end
		end

		puts "<br />"
	end

	def self.uploadpage
		puts '<h2 class="alt">Upload a file</h2><hr>'
		puts '<form method="POST" enctype="multipart/form-data" action="uploader.rb">'
		puts '<label>File : <input type="file" name="file" size="100"/></label><br />'
		puts '<input type="submit" value="Upload" />'
		puts '</form>'
		puts '<br/>'
	end

	def self.htmlfooter
        	puts "<hr>"
        	puts '<h4 align=right><span class="alt">A Ruby Browser by <a href="http://blog.khemael.net">Khemael</a> - Licensed under <a href="http://sam.zoy.org/wtfpl/">WTFPL</a></span></h4>'
        	puts "</div>"
        	puts "</body></html>"
	end

	def self.htmlheader
        	puts "<html>"
        	puts "<head>"
        	puts '<link href="'+$admindir+'/css/screen.css" media="screen" rel="stylesheet" type="text/css" />'
        	puts '<link href="'+$admindir+'/css/fancy.css" media="screen" rel="stylesheet" type="text/css" />'
                puts '<link href="'+$admindir+'/css/shadowbox.css" media="screen" rel="stylesheet" type="text/css" />'
		puts '<script type="text/javascript" src="'+$admindir+'/js/shadowbox.js"></script>'
        	puts "</head>"
        	puts "<body>"
		puts '<script type="text/javascript">Shadowbox.init();</script>'
        	puts '<div class="container">'
        	puts '<center><a href="'+$admindir+'/root" style="text-decoration:none"><h1 class="alt">'+$title+'</h1></a></center>'
		puts '<ul id="tabnav"><li class="tab1"><a href="'+$admindir+'/root">Files</a></li><li class ="tab2"><a href="'+$admindir+'/upload">Uploader</a></li></ul>'
	end
	
end
