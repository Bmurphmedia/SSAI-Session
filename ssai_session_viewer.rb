
require 'net/http'
require 'json'
require 'nokogiri'

class SeamlessSession
	attr_accessor :response, :vmap_url, :vmap, :ads, :ad_break, :ad_array, :ad_list
	def initialize(mgid)
		uri = URI('http://seamless-dev.mtvnservices.com/api/'+mgid+'/vmap.json?proxy=true&SMSYSdebug=ads&SMADfwToS3=true&SMCRarcPlatforms=7ac7942e-6481-457f-b39a-2b1aedb29f29,b995f21c-e76f-4e58-8d0f-0964dc76efd3,6caa8f01-72e5-4707-abd6-608a0146e2ee,39dfe10c-cc2a-40f9-a20d-962d2604d543,0a16f611-d105-436a-8188-33ea8871171e,f17d0e9b-657a-4785-b3ca-dae9e78563a1&format=json&acceptMethods=hls')
		req = Net::HTTP::Get.new(uri)
		req["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"

		res = Net::HTTP.new(uri.host, uri.port).start do |http|
  		http.request(req)
		end
		self.response = JSON.parse(res.body)
		#self.vmap_url = self.response["Freewheel vmap url:"]
		#self.vmap = get_vmap(self.vmap_url)
		self.ad_break = get_ad_break(self.response)
		self.ad_array = get_ad_array(self.ad_break)
		self.ad_list = get_list(self.ad_array)
	end

	
	def get_ad_break(response)
		ad_breaks = response['vmap:VMAP']['vmap:AdBreak']
		puts ad_breaks.class

		return response['vmap:VMAP']['vmap:AdBreak']

	end

	def get_ad_array(ad_break)
		array = []
		i = 0
		ad_break.each do |pod|
			pod['vmap:AdSource']['vmap:VASTAdData']['VAST']['Ad'].each do |ad|
				array[i] = ad['@id'].split(".").first
				i += 1
			end

		end
		return array

	end
	def get_list(array)
		string = ''
		array.each do |id|
			string += id + ","
		end
		return string
	end

	def get_vmap(url)
		uri = URI(url)
		req = Net::HTTP::Get.new(uri)
		res = Net::HTTP.new(uri.host, uri.port).start do |http|
  		http.request(req)
		end
		return res.body

	end

	def get_ads(vmap)
		doc = Nokogiri::XML(vmap)
		return doc.class
		ads = doc.xpath("//Ad")
	
		return ads.class
		

	end


end

session = SeamlessSession.new('mgid:arc:episode:mtv.com:b6b73812-5fde-11e8-881b-70df2f866ace')

puts session.ad_list
#puts session.vmap
