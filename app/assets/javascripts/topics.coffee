//= require jquery.autogrow-textarea
# TopicsController 下所有页面的 JS 功能
window.Topics =
  # 往话题编辑器里面插入图片代码
  appendImageFromUpload : (srcs) ->
    txtBox = $(".topic_editor")
    for src in srcs
      txtBox.val("#{txtBox.val()}[img]#{src}[/img]\n")
    txtBox.focus()
    $("#add_image").jDialog.close()

  # 上传图片
  addImageClick : () ->
    opts =
      title:"插入图片"
      width: 350
      height: 145
      content: '<iframe src="/photos/tiny_new" frameborder="0" style="width:330px; height:145px;"></iframe>',
      close_on_body_click : false
    
    $("#add_image").jDialog(opts)
    return false

  # 回复
  reply : (floor,login) ->
    reply_body = $("#reply_body")
    new_text = "##{floor}楼 @#{login} "
    if reply_body.val().trim().length == 0
      new_text += ''
    else
      new_text = "\n#{new_text}"
    reply_body.focus().val(reply_body.val() + new_text)
    return false

  # 高亮楼层
  hightlightReply : (floor) ->
    $("#replies .reply").removeClass("light")
    $("#reply"+floor).addClass("light")

  # Ajax 回复后的事件
  replyCallback : (success, msg) ->
    $("#main .alert-message").remove()
    if success
      $("abbr.timeago",$("#replies .reply").last()).timeago()
      $("#new_reply textarea").val('')
      App.notice(msg,'#reply')
    else
      App.alert(msg,'#reply')
    $("#new_reply textarea").focus()
    $('#btn_reply').button('reset')    
    
  preview: (body, callback) ->
    $("#preview").text "Loading..."

    $.post "/topics/preview",
      "body": body,
      (data) ->
        $("#preview").html data.body
        callback.call()
      "json"

  hookPreview: (switcher, textarea) ->
    # put div#preview after textarea
    preview_box = $(document.createElement("div")).attr "id", "preview"
    $(textarea).after preview_box
    preview_box.hide()

    $(switcher).click ->
      if Topics.duringPreview is true
        # turn off preview
        $(preview_box).hide()
        $(textarea).show()
        Topics.duringPreview = false
        $(switcher).text "預覽"
      else
        # turn on preview
        $(preview_box).show()
        $(textarea).hide()
        Topics.duringPreview = true
        Topics.preview $(textarea).val(),
          () ->
            $(switcher).text "撰寫"
      false

# pages ready
$(document).ready ->
  $("textarea").bind "keydown","ctrl+return",(el) ->
    if $(el.target).val().trim().length > 0
      $("#reply form").submit()
    return false

  $("textarea").autogrow()

  Topics.hookPreview($("#switch-preview"), $(".topic_editor"))
  return
