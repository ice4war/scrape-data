#!/bin/env ruby
require 'open-uri'
require 'net/http'
require 'nokogiri'
require "json"
require "fileutils"

def outFile(fname,data)
	dir = fname.split("/")
	dir.slice!(-1)
	if Dir.exist?(dir.join("/"))
		File.write(fname,JSON.pretty_generate(data))
	else
		FileUtils::mkdir_p dir.join("/")
		File.write(fname,JSON.pretty_generate(data))
	end
end

def getDoc(url)
	uri = URI.parse(url)
	response = Net::HTTP.get_response(uri)
	html = response.body

	doc = Nokogiri::HTML5(html)
	return doc
end

def andriod(url)
	doc = getDoc(url)	
	article = doc.css("article")
	a = article.css("td > a")

	href = []
	a.each do |a|
		href.append(a.attributes["href"].value)
	end

	title = []
	links = []
	heading = []
	h1 = article.css("h1[1]")
	
	h1.each do |h|
		heading.append(h.text)
	end
	href.each do |l|
		if !l.match?(/^\/|license|githubusercontent|LICENSE|.gif$|None|png|facebook/)
			links.append(l)
		end
	end

	article.css("tbody").css("tr > td[1]").each do |t|
		title.append(t.text)
	end

	children = []
	for i in (0...links.length)
		obj = {
			name: title[i],
			url: links[i]
		}
		children.append(obj)
	end

	outFile("./androidui/heading.json",heading)
	outFile("./androidui/items.json",children)
end

def list_format(url,start,head="h3")
	doc = getDoc(url)
	article = doc.css("article")
	ul = article.css("ul")

	heading = []
	data = []

	article.css(head).each do |d|
		heading.append(d.text)
	end

	for i in (start...ul.length)
		subLink = ul[i].css("li > a[1]")
		subLabel = ul[i].css("li")

		urls = []
		name = []
		desc = []
		subLink.each do |l|
			urls.append(l.attributes["href"].value)
		end

		subLabel.each do |l|
			text = l.text.split(" - ")
			name.append(text[0])
			desc.append(text[1])
		end

		for i in (0...urls.length)
				obj = {"name": name[i],"url": urls[i],"description":desc[i]}
				data.append(obj)
		end
	end
	return data,heading
end

def export(dirname,url,start,h)
	data,heading = list_format(url,start,h)
	outFile("#{dirname}/items.json",data)
	outFile("#{dirname}/heading.json",heading)
end

android_url = "https://github.com/wasabeef/awesome-android-ui"
java_url = "https://github.com/akullpp/awesome-java"
vue_url = "https://github.com/vuejs/awesome-vue"
php_url = "https://github.com/ziadoz/awesome-php"
django_url = "https://github.com/wsvincent/awesome-django"
tf_url = "https://github.com/jtoy/awesome-tensorflow"
docker_url = "https://github.com/veggiemonk/awesome-docker"
sysadmin_url = "https://github.com/kahun/awesome-sysadmin"
ml_url = "https://github.com/josephmisiti/awesome-machine-learning"
r_url = "https://github.com/qinwf/awesome-R"
micro_url = "https://github.com/mfornos/awesome-microservices"
rust_url = "https://github.com/rust-unofficial/awesome-rust"
elixir_url = "https://github.com/h4cc/awesome-elixir"
mal_url = "https://github.com/rshipp/awesome-malware-analysis"
# andriod(android_url)

# export("java",java_url,3,'h3')
# export('vue',vue_url,19,'h3')
# export('php',php_url,4,'h3')
# export('django',django_url,7,'h3')
# export('tensorflow',tf_url,1,'h2')
# export('docker',docker_url,11,'h1')
# export('sys-admin',sysadmin_url,3,'h2')
# export('ml',ml_url,39,'h4')
# export('R',r_url,3,'h2')
# export('microservice',micro_url,6,'h2')
# export("rust",rust_url,5,'h2')
export('elixir',elixir_url,3,'h2')
export('malware-analysis',mal_url,4,'h3')