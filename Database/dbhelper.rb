# encoding: utf-8

require "sequel"
require_relative "../WikiParser/entity"


class DbHelper
	Sequel::Model.plugin :schema

	def initialize
		@db = Sequel.sqlite('/Users/ultragtx/DevProjects/Ruby/WikipediaEntityAnalyser/Database/test.db')

		unless @db.table_exists?(:pages)
			@db.create_table :pages do
				primary_key :id
				String :title
				String :ns
				String :redirect
				String :revid
				String :parentid
				String :timestamp
				String :minor
				String :sha1

				String :infobox_type
				String :properties
				String :aliases
				String :aliases_forien
			end
		end

		@pages = @db[:pages]
	end

	def insert_page(page)
		@pages.insert(
			:id => page.id,
			:title => page.title,
			:ns => page.ns,
			:redirect => page.redirect,
			:revid => page.revid,
			:parentid => page.parentid,
			:timestamp => page.timestamp,
			:minor => page.minor,
			:sha1 => page.sha1,
			:infobox_type => page.infobox_type,
			:properties => page.properties,
			:aliases => page.aliases,
			:aliases_forien => page.aliases_forien)
	end

	def page_with_title(title)
		# page_data = @pages.where(:title.like('%#{title}%')).first
		# puts title
		page_data = @pages[:title=>title]
		# puts page_data
		# page_data = eval(page_data)

		page = Page.new

		if page_data
			page.id = page_data[:id]
			page.title = page_data[:title]
			page.ns = page_data[:ns]
			page.redirect = page_data[:redirect]
			page.revid = page_data[:revid]
			page.parentid = page_data[:parentid]
			page.timestamp = page_data[:timestamp]
			page.minor = page_data[:minor]
			page.sha1 = page_data[:sha1]
			page.infobox_type = page_data[:infobox_type]
			page.properties = page_data[:properties]
			page.aliases = page_data[:aliases]
			page.aliases_forien = page_data[:aliases_forien]
		end
		return page
	end

end
