class Contributor
  attr_accessor :username, :id

  def to_s
    "username:#{@username}\nid:#{@id}"
  end
end

class Revision
  attr_accessor :id, :parentid, :timestamp, :contributor, :minor, :comment, :text, :sha1, :model, :format

  def to_s
    "id:#{@id}\nparentid:#{@parentid}\ntimestamp:#{@timestamp}\ncontributor:\n#{@contributor}\nminor:#{@minor}\ncomment:#{@comment}\ntext:#{@text}\nsha1:#{@sha1}\nmodel:#{@model}\nformat:#{@format}"
  end
end

class Page
  attr_accessor :title, :ns, :id, :redirect, :revision
  
  def to_s
    "title:#{@title}\nns:#{@ns}\nid:#{id}\nredirect:#{@reidrect}\nrevision:\n#{@revision}\n"
  end
end
