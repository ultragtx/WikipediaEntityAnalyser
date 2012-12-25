require "sinatra"
require "open-uri"
require_relative '../Database/dbhelper'

CURRENT_PAGE = Page.new
DBHELPER = DbHelper.new

get '/' do
	erb :index
end


get '/s' do
	# puts request.query_string
	# puts URI::decode(request.query_string)
	# 
	text = URI::decode(request.query_string).split('=')[1]

	CURRENT_PAGE = DBHELPER.page_with_title(text) if text
	CURRENT_PAGE.properties = eval(CURRENT_PAGE.properties.to_s)
	CURRENT_PAGE.aliases = eval(CURRENT_PAGE.aliases.to_s)
	CURRENT_PAGE.aliases_forien = eval(CURRENT_PAGE.aliases_forien.to_s)

	# puts CURRENT_PAGE.title
	# puts CURRENT_PAGE.infobox_type
	# puts CURRENT_PAGE.properties
	# puts CURRENT_PAGE.aliases
	# puts CURRENT_PAGE.aliases_forien
	# 
	erb :index


	# if CURRENT_PAGE.title
	# 	CURRENT_PAGE.infobox_type

	# 	CURRENT_PAGE.aliases.each do |aliase_name |
	# 		aliase_name
	# 	end

	# 	CURRENT_PAGE.properties.each do |key, value|
	# 		key
	# 		value
	# 	end

	# 	CURRENT_PAGE.aliases_forien do |key, value|
	# 		key
	# 		value
	# 	end

	# else

	# end

	
end