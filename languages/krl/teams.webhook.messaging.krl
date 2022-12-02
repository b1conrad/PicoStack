ruleset teams.webhook.messaging {
  global {
    webhook = meta:rulesetConfig{"webhook"}
  }
  rule sendMessage {
    select when byname_notification status
      application re#(org.picostack.get_me_ribs)#
      subject re#(Cannon Has .+)#
      description re#(.+)#
      setting(app,subj,desc)
    http:post(webhook,json={"title":subj,"text":desc}) setting(response)
  }
}
