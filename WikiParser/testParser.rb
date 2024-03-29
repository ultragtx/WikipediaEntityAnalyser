# encoding: utf-8

require 'libxml'
require 'bzip2'
require_relative 'entity'
require_relative '../Database/dbhelper'

class SaxCallbacks
  include LibXML::XML::SaxParser::Callbacks
  
  attr_accessor :start_time, :end_time  # for test
  
  attr_accessor :pages
  
  def initialize
    @in_page = false
    @in_title = @in_ns = @in_id = @in_redirect = @in_revision = false
    @in_revid = @in_parentid = @in_timestamp = @in_contributor = false
    @in_username = @in_conid = false
    @in_minor = @in_comment = @in_text = @in_sha1 = @in_model = @in_format = false
    
    @pages = []
    
    @infobox_hash = Hash.new
    @info_count = 0
    
    @page_count = 0

    @dbhelper = DbHelper.new
  end
  
  def on_start_document
    @start_time = Time.now
    puts "on_start_document"
  end
  
  def on_end_document
    @end_time = Time.now
    # @infobox_hash.keys.each {|key| puts "@@#{key}$$"}
    @infobox_hash.keys.each {|key| puts "#{key}"}
    # @infobox_hash.each {|key| puts "#{key}"}
    puts "total info:#{@infobox_hash.count}"
    puts "on_end_document"
    puts "count:#{@info_count}"
    puts (@end_time - @start_time).to_s
  end
  
  def on_start_element_ns(name, attributes, prefix, uri, namespaces)
    # puts "#{name} | #{attributes} | #{prefix} | #{uri} | #{namespaces}"
    # puts "<#{name}>"
    @useful_element = true
    if @in_contributor
      case name
      when "username"
        @in_username = true
      when "id"
        @in_conid = true
      end
    elsif @in_revision
      case name
      when "id"
        @in_revid = true
      when "parentid"
        @in_parentid = true
      when "timestamp"
        @in_timestamp = true
      when "contributor"
        @in_contributor = true
        @useful_element = false
        # @current_page.revision.contributor = Contributor.new
      when "minor"
        @in_minor = true
      when "comment"
        @in_comment = true
      when "text"
        @in_text = true
      when "sha1"
        @in_sha1 = true
      when "model"
        @in_model = true
      when "format"
        @in_format = true
      end
    elsif @in_page
      case name
      when "title"
        @in_title = true
      when "ns"
        @in_ns = true
      when "id"
        @in_id = true
      when "redirect"
        @in_redirect = true
      when "revision"
        @in_revision = true
        @useful_element = false
        # @current_page.revision = Revision.new
      end
    elsif name == "page"
      @in_page = true

      @current_page = Page.new
      @useful_page = false

      @useful_element = false
    else
      @useful_element = false
    end
    
    if @useful_element
      @current_string = String.new
    else
      @current_string = nil
    end
  end
  
  def on_end_element_ns(name, prefix, uri)
    # puts "</#{name}>"
    if @in_contributor
      case name
      when "username"
        @in_username = false
        # @current_page.revision.contributor.username = @current_string
      when "id"
        @in_conid = false
        # @current_page.revision.contributor.id = @current_string
      when "contributor"
        @in_contributor = false
      end
    elsif @in_revision
      case name
      when "id"
        @in_revid = false
        # @current_page.revision.id = @current_string
        @current_page.revid = @current_string
      when "parentid"
        @in_parentid = false
        # @current_page.revision.parentid = @current_string
        @current_page.parentid = @current_string
      when "timestamp"
        @in_timestamp = false
        # @current_page.revision.timestamp = @current_string
        @current_page.timestamp = @current_string
      when "minor"
        @in_minor = false
        # @current_page.revision.minor = @current_string
        @current_page.minor = @current_string
      when "comment"
        @in_comment = false
        # @current_page.revision.comment = @current_string
        @current_page.comment = @current_string
      when "text"
        @in_text = false
        # @current_page.revision.text = @current_string
        self.get_info
      when "sha1"
        @in_sha1 = false
        # @current_page.revision.sha1 = @current_string
        @current_page.sha1 = @current_string
      when "model"
        @in_model = false
        # @current_page.revision.model = @current_string
        @current_page.model = @current_string
      when "format"
        @in_format = false
        # @current_page.revision.format = @current_string
        @current_page.format = @current_string
      when "revision"
        @in_revision = false
      end
    elsif @in_page
      case name
      when "title"
        @in_title = false
        @current_page.title = @current_string
      when "ns"
        @in_ns = false
        @current_page.ns = @current_string
      when "id"
        @in_id = false
        @current_page.id = @current_string
      when "redirect"
        @in_redirect = false
        @current_page.redirect = @current_string
      when "page"
        @in_page = false
        # @pages += [@current_page]
        # puts "$$#{@current_page}$$"

        if @useful_page
          @dbhelper.insert_page(@current_page)
        end

      end
    end
    @current_string = nil
  end
  
  def on_characters(chars)
    # printf("$$#{chars[0..[20, chars.length].min]}%%%\n")
    if @current_string
      @current_string << chars
    end
  end
  
  def get_info
    if @page_count >= 0
      if self.get_infobox      
        @useful_page = true  
        self.get_alias
        self.get_forien_alias

        # gets
      end
    end
    @page_count += 1
  end
  
  def get_infobox
    useful_type = false
    
    infobox_content_exp = /^{{(Infobox.*?)^\|?}}/m
    @current_string =~ infobox_content_exp
    infobox_content = $1
    
    if infobox_content
      infobox_type_exp = /^Infobox(.*?)(\||\}|\<!)/m
      infobox_content =~ infobox_type_exp
      infobox_type = $1.to_s
      infobox_type.gsub!(/_/, " ")
      infobox_type.strip!
      infobox_type.downcase!
      
      @current_page.infobox_type = infobox_type

      if infobox_type == "company"
        useful_type = true

        # puts "--------Page [#{@page_count}]----------"
        # puts "title:#{@current_page.title}"
        # puts "infobox_type:#{infobox_type}"
    
        # append_tails = ["\n|", "\n |"]
        # chomp_tails = [nil, "\n|"]
        infobox_key_value_pair_exps = [/^\s*\|(.*?)=(.*?)(?=^\s*\||\|\s*$|\z)/m, /\|\s*$(.*?)=(.*?)(?=\|\s*$|\z)/m]
        
        for i in 0...infobox_key_value_pair_exps.count
          # infobox_content.chomp!(chomp_tails[i])
          # infobox_content << append_tails[i]
          infobox_properties = Hash.new
          infobox_content.scan(infobox_key_value_pair_exps[i]) do |key, value|
            # puts "debug:#{key}, #{value}"
            infobox_properties[key.strip!] = value.strip!

            # puts "infobox_properties:#{key}, #{value}"

          end
          
          break unless infobox_properties.empty?
        end

        @current_page.properties = infobox_properties.to_s

      end
    end
    
    return useful_type
  end
  
  def get_alias
    main_paragraph_exp = /^('''.*?)$/
    @current_string =~ main_paragraph_exp
    main_paragraph = $1
    
    if main_paragraph
      alias_names_exp = /'''(.+?)'''/
      aliases = []
      main_paragraph.scan(alias_names_exp) do |alias_name|

        # puts "alias_names:#{alias_name[0]}"
        
        aliases << alias_name
      end

      @current_page.aliases = aliases.to_s

    end
    
    # if $~
    #       alias_names = $~.captures
    #     
    #       alias_names.each do |alias_name|
    #         puts "alias_names:#{alias_name}"
    #       end
    #     end
  end
  
  def get_forien_alias
    en_alias_exp = /^\[\[en:(.*?)\]\]$/
    zh_alias_exp = /^\[\[zh:(.*?)\]\]$/
    ja_alias_exp = /^\[\[ja:(.*?)\]\]$/
    
    @current_string =~ en_alias_exp
    en_alias = $1
    
    @current_string =~ zh_alias_exp
    zh_alias = $1
    
    @current_string =~ ja_alias_exp
    ja_alias = $1
    
    aliases_forien = Hash.new

    # puts "en_alias:#{en_alias}"
    # puts "zh_alias:#{zh_alias}"
    # puts "ja_alias:#{ja_alias}"

    aliases_forien[:en] = en_alias
    aliases_forien[:zh] = zh_alias
    aliases_forien[:ja] = ja_alias

    @current_page.aliases_forien = aliases_forien.to_s

  end
  
  def get_category
    categorys_exp = /^\[\[Category:(.*?)\]\]$/
    @current_string.scan(categorys_exp)
    
  end
  
  # def get_info
  #     infobox_exp = /\{\{Infobox((.)*?)(\||\}|\<!)/m
  #     @current_string =~ infobox_exp
  #     key = $1.to_s
  #     key.gsub!(/_/, " ")
  #     key.strip!
  #     key.downcase!
  #     if key.length > 0
  #       # puts "@@#{$1.chomp}$$"
  #       @infobox_hash[key] = @current_page.title
  #       @info_count += 1
  #     end
  #   end
end

file_path_bz2 = "/Users/ultragtx/Downloads/zhwiki-latest-pages-articles.xml.bz2"
#file_path_bz2 = "/Users/ultragtx/Downloads/enwiki-latest-pages-articles1-1.xml-p000000010p000010000.bz2"
file_path = "/Users/ultragtx/Downloads/zhwiki-latest-pages-articles.xml"
#file_path = "/Users/ultragtx/Downloads/enwiki-latest-pages-articles1-1.xml-p000000010p000010000"

USE_COMPRESSED_FILE = false

if USE_COMPRESSED_FILE
  bz2_reader = Bzip2::Reader.open(file_path_bz2)
  parser = LibXML::XML::SaxParser.io(bz2_reader)
else
  parser = LibXML::XML::SaxParser.file(file_path)
end

parser.callbacks = SaxCallbacks.new
parser.parse
