#encoding:utf-8

require 'libxml'
require 'bzip2'
require_relative 'entity'

class SaxCallbacks
  include LibXML::XML::SaxParser::Callbacks
  
  attr_accessor :start_time, :end_time  # for test
  
  # the labels
  attr_accessor :in_page
  attr_accessor :in_title, :in_ns, :in_id, :in_redirect, :in_revision
  attr_accessor :in_revid, :in_parentid, :in_timestamp, :in_contributor
  attr_accessor :in_username, :in_conid
  attr_accessor :in_minor, :in_comment, :in_text, :in_sha1, :in_model, :in_format 
    
  attr_accessor :pages
  
  def initialize
    @in_page = false
    @in_title = @in_ns = @in_id = @in_redirect = @in_revision = false
    @in_revid = @in_parentid = @in_timestamp = @in_contributor = false
    @in_username = @in_conid = false
    @in_minor = @in_comment = @in_text = @in_sha1 = @in_model = @in_format = false
    
    @pages = []
  end
  
  def on_start_document
    @start_time = Time.now
    puts "on_start_document"
  end
  
  def on_end_document
    @end_time = Time.now
    puts "on_end_document"
    puts (@end_time - @start_time).to_s
  end
  
  def on_start_element_ns(name, attributes, prefix, uri, namespaces)
    # puts "#{name} | #{attributes} | #{prefix} | #{uri} | #{namespaces}"
    # puts "#{name}"
    if @in_contributor
      case name
      when "username"
        @in_username = true
        puts "<username>"
      when "id"
        @in_conid = true
        puts "<conid>"
      end
    elsif @in_revision
      case name
      when "id"
        @in_revid = true
        puts "<revid>"
      when "parentid"
        @in_parentid = true
        puts "<parentid>"
      when "timestamp"
        @in_timestamp = true
        puts "<timestamp>"
      when "contributor"
        @in_contributor = true
        puts "<contributor>"
      when "minor"
        @in_minor = true
        puts "<minor>"
      when "comment"
        @in_comment = true
        puts "<comment>"
      when "text"
        @in_text = true
        puts "<text>"
      when "sha1"
        @in_sha1 = true
        puts "<sha1>"
      when "model"
        @in_model = true
        puts "<model>"
      when "format"
        @in_format = true
        puts "<format>"
      end
    elsif @in_page
      case name
      when "title"
        @in_title = true
        puts "<title>"
      when "ns"
        @in_ns = true
        puts "<ns>"
      when "id"
        @in_id = true
        puts "<id>"
      when "redirect"
        @in_redirect = true
        puts "<redirect>"
      when "revision"
        @in_revision = true
        puts "<revision>"
      end
    elsif name == "page"
      @in_page = true
      puts "<page>"
      @currentPage = Page.new
    else
      puts "[WARNING]: New Element Start"
    end
    
  end
  
  def on_end_element_ns(name, prefix, uri)
    if @in_contributor
      case name
      when "username"
        @in_username = false
        puts "<username>"
      when "id"
        @in_conid = false
        puts "<conid>"
      when "contributor"
        @in_contributor = false
        puts "<contributor>"
      end
    elsif @in_revision
      case name
      when "id"
        @in_revid = false
        puts "<revid>"
      when "parentid"
        @in_parentid = false
        puts "<parentid>"
      when "timestamp"
        @in_timestamp = false
        puts "<timestamp>"
      when "minor"
        @in_minor = false
        puts "<minor>"
      when "comment"
        @in_comment = false
        puts "<comment>"
      when "text"
        @in_text = false
        puts "<text>"
      when "sha1"
        @in_sha1 = false
        puts "<sha1>"
      when "model"
        @in_model = false
        puts "<model>"
      when "format"
        @in_format = false
        puts "<format>"
      when "revision"
        @in_revision = false
        puts "<revision>"
      end
    elsif @in_page
      case name
      when "title"
        @in_title = false
        puts "<title>"
      when "ns"
        @in_ns = false
        puts "<ns>"
      when "id"
        @in_id = false
        puts "<id>"
      when "redirect"
        @in_redirect = false
        puts "<redirect>"
      when "page"
        @in_page = false
        puts "<page>"
        @pages += [@currentPage]
      end
    else
      puts "[WARNING]: New Element End"
    end
  end
  
  def on_characters(chars)
    printf("$$#{chars[0..[20, chars.length].min]}%%\n")
  end
end

file_path_bz2 = "/Users/ultragtx/Downloads/zhwiki-latest-pages-articles.xml.bz2"
file_path_bz2 = "/Users/ultragtx/Downloads/enwiki-latest-pages-articles1-1.xml-p000000010p000010000.bz2"
file_path = "/Users/ultragtx/Downloads/enwiki-latest-pages-articles1-1.xml-p000000010p000010000"

USE_COMPRESSED_FILE = false

if USE_COMPRESSED_FILE
  bz2_reader = Bzip2::Reader.open(file_path_bz2)
  parser = LibXML::XML::SaxParser.io(bz2_reader)
else
  parser = LibXML::XML::SaxParser.file(file_path)
end

parser.callbacks = SaxCallbacks.new
parser.parse
