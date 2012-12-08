class Contributor
  attr_accessor :username, :id
  
  # def initialize(username, id)
  #     @username = username
  #     @id = id
  #   end
  
  def to_s
    printf("username:#{@username}\nid:#{@id}\n")
  end
end

class Revision
  attr_accessor :id, :parentid, :timestamp, :contributor, :minor, :comment, :text
  
  # def initialize(id, parentid, timestamp, contributor, minor, comment, text)
  #     @id = id
  #     @parentid = parentid
  #     @timestamp = timestamp
  #     @contributor = contributor
  #     @minor = minor
  #     @comment = comment
  #     @text = text
  #   end
  
  def to_s
    printf("id:#{@id}\nparentid:#{@parentid}\ntimestamp:#{@timestamp}\ncontributor:\n#{@contributor}\nminor:#{@minor}\ncomment:#{@comment}\ntext#{@text}\n")
  end
end

class Page
  attr_accessor :title, :ns, :id, :revision
  
  # def initialize(title, ns, id, revision)
  #     @title = title
  #     @ns = ns
  #     @id = id
  #     @revision = revision
  #   end
  
  def to_s
    printf("title:#{@title}\nns:#{@ns}\nid:#{id}\nrevision:\n#{revision}\n")
  end
end
