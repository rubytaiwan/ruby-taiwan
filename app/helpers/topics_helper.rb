# coding: utf-8  
module TopicsHelper
  def format_topic_body(text, options = {})

    options[:title] ||= ''
    options[:allow_image] ||= true
    options[:mentioned_user_logins] ||= []
    options[:class] ||= ''

    text = h(text)
    
    text = preformat_fenced_code_block(text)

    ## fenced code block with ```
    text = parse_fenced_code_block(text)
    
    # simple_format must be front of format_topic_body, because it will remove html attrs, etc .. onclick
    text = simple_format(text)
    
    # fix code after simple_format
    text = reformat_code_block(text) do |code|
      code.gsub!(/<br\s?\/?>/, "")  # remove <br>
      code.gsub!(/<\/?p>/, "")      # remove <p>
    end

    text = parse_paragraph(text) do |token|
      # additional parsing here

      # parse bbcode-style image [img]url[/img]
      token = parse_bbcode_image(token, options[:title]) if options[:allow_image]

      # Auto Link
      token = auto_link(token,:all, :target => '_blank', :rel => "nofollow")

      # mention floor by #
      token = link_mention_floor(token)

      # mention user by @
      token = link_mention_user(token, options[:mentioned_user_logins])

      # [[wiki]] or [[Title|wiki]]
      token = parse_wiki_page_link(token)

      token
    end

    return raw(text)

  end

  # **text** => <strong>text</strong>
  def strongify!(text)
    text.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
  end

  # *text* => <em>text</em>
  def emphasize!(text)
    text.gsub!(/\*(.+?)\*/, '<em>\1</em>')
  end

  # `text` => <code>text</code>
  def codify!(text)
    text.gsub!(/`(.+?)`/, '<code>\1</code>')
  end

  def parse_inline_styles(text, &block)
    # sample input and output:
    # normal text                      =>  normal text
    # `code` **bold**                  =>  <code>code</code> <strong>bold</strong>
    # *italic* `code`                  =>  <em>italic</em> <code>code</code>
    # *italic* `code` **bold**         =>  <em>italic</em> <code>code</code> <strong>bold</strong>
    # `co*d*e` **bold** *italic`*      =>  <code>co*d*e</code> <strong>bold</strong> <em>italic`</em>
    # *italic* `c**od**e` **`bold**    =>  <em>italic</em> <code>c**od**e</code> <strong>`bold</strong>
    # *italic* `code` **bold**         =>  <em>italic</em> <code>code</code> <strong>bold</strong>

    # Some syntax may not be parsed as expected by some people,
    # but as long as the results is same as on Github, it is acceptible.
    # e.g.:
    # *ita`lic* `c**od**e` **`bold**   =>  *ita<code>lic*</code>c<strong>od</strong>e<code>**</code>bold**
    # *i`talic* `code` **bo`ld**       =>  *i<code>talic*</code>code<code>**bo</code>ld**

    # splitting by a Regexp with groups will get an array
    # with the splitted strings as well as extracted groups
    # at the corresponding position.
    # e.g.:
    # "some `code` here".split(/(`.+?`)/) => ["some", "`code`", "here"]
    # "`code` only" => ["", "`code`", "only"]
    # Since the matched group is also the whole tokenizer,
    # we can assume that the first (0th) token is not `code`,
    # and then `code`, and then not code, and then `code`, till the end.

    in_code = false

    tokens = text.split(/(`.+?`)/)
    tokens.map! do |token|
      if !in_code
        strongify!(token)
        emphasize!(token)
        token = block.call(token) if block_given?
        in_code = true
      else
        codify!(token)
        in_code = false
      end

      token # return the manipulated token string
    end

    return tokens.join("")
  end

  # parse_inline_styles assumes that:
  # - all the texts to be applied are already wrapped with <p>
  #   i.e. <p> is only one-level deep; and
  # - <pre> is in the top level, not in a <p>
  # the parse_inline_styles only applys on " > p" elements
  def parse_paragraph(text, &block)
    doc = Hpricot(text)

    (doc.search('/p')).each do |paragraph|

      next if paragraph.search('pre').size != 0

      source = String.new(paragraph.inner_html) # avoid SafeBuffer

      paragraph.inner_html = parse_inline_styles(source) do |token|
        token = block.call(token) if block_given?
      end
    end

    doc.to_html
  end

  # add new lines before and after the fenced code block
  # to avoid <br> in front of and ends 
  def preformat_fenced_code_block(text)
    text.gsub(/(```.+?```)/im, "\n\\1\n")
  end

  def parse_fenced_code_block(text)
    source = String.new(text.to_s)
    source.gsub!(/(^```.+?```)/im) do

      code = CGI::unescapeHTML($1)
    
      #code = $1
      #code = code.sub!("\r\n", "")

      # let the markdown compiler draw the <pre><code>
      # (with syntax highlighting) 
      MarkdownConverter.convert(code)
    end
    
    # remove last break line, if not, simple_format will add a <br>
    source.gsub!(/<\/pre>[\s]+/im,"</pre>")

    return source
  end

  def reformat_code_block(text, &block)
    # XXX: ActionView uses SafeBuffer, not String
    # and it's gsub is different from String#gsub
    # which makes gsub with block unusable.

    source = String.new(text.to_s)

    source.gsub!(/<pre>(.+?)<\/pre>/mi) do |matched|
      code = $1

      block.call(code)

      "<pre>#{code}</pre>"
    end
    source
  end

  def parse_bbcode_image(text, title)
    source = String.new(text.to_s)
    source.gsub!(/\[img\](http:\/\/.+?)\[\/img\]/i) do
      src = $1
      image_tag(src, :alt => title)
    end
    source
  end

  # [[slug]] => <a href="/wiki/slug">Page's Title</a>
  # [[custom title|slug]] => <a href="/wiki/slug">Custom Title</a>
  # The class name will be "wiki present" if wiki page exists,
  #                        "wiki absent"  otherwise.
  def parse_wiki_page_link(text)
    valid_chars = /[^\]\|]/  # not ], not |
    text.gsub(/\[\[((#{valid_chars}+?)\|)?(#{valid_chars}+?)\]\]/) do |matched|
      _garbage, title, slug = $1, $2, $3

      wiki = Wiki.find(slug)
      if !wiki
        # absent
        title = slug if title.blank?
        link_to(title, giki_path(slug), :class => 'wiki absent')
      else
        # present
        title = wiki.name if title.blank?
        link_to(title, giki_path(wiki.name), :class => 'wiki present')
      end
    end
  end

  def link_mention_floor(text)
    source = String.new(text.to_s)
    # matches #X樓, #X楼, #XF, #Xf, with or without :
    # doesn't care if there is a space after the mention command
    expression = /#([\d]+)([楼樓Ff]\s?)/

    source.gsub!(expression) do |floor_token|
      floorish, postfix = $1, $2

      html_options = {
        :class => "at_floor", "data-floor" => floorish,
        :onclick => "return Topics.hightlightReply(#{floorish})"
      }

      link_to(floor_token, "#reply#{floorish}", html_options)
    end
    source
  end

  def link_mention_user(text, mentioned_user_logins)
    return text if mentioned_user_logins.blank?
    source = String.new(text.to_s)
    source.gsub!(/@(#{mentioned_user_logins.join('|')})/i) do |mention_token|
      user_name = $1
      link_to(mention_token, user_path(user_name), 
              :class => "at_user", :title => mention_token)
    end
    source
  end
  
  def topic_use_readed_text(state)
    case state
    when true
      t("topics.have_no_new_reply")
    else
      t("topics.has_new_replies")
    end
  end

  def render_topic_title(topic)
    return t("topics.topic_was_deleted") if topic.blank?
    link_to(topic.title, topic_path(topic), :title => topic.title)
  end
  
  def render_topic_last_reply_time(topic)
    l((topic.replied_at || topic.created_at), :format => :short)
  end
  
  def render_topic_count(topic)
    topic.replies.count
  end
  
  def render_topic_created_at(topic)
    timeago(topic.created_at)
  end
  
  def render_topic_last_be_replied_time(topic)
    timeago(topic.replied_at)
  end
end
