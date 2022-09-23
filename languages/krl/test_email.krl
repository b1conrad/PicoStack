ruleset test_email {
  meta {
    use module com.mailjet.sdk alias email
    shares last_response, last_content
  }
  global {
    last_response = function(){
      ent:lastResponse
    }
    last_content = function(){
      ent:lastResponse
        .get("content")
        .decode()
    }
  }
  rule firstEmail {
    select when test_email first_email
      name re#(.+)# setting(name)
    email:send_first(name) setting(response)
    fired {
      raise test_email event "message_sent" attributes response
    }
  }
  rule sendMinimalMessage {
    select when test_email new_text_message
      to re#(.+)# subject re#(.+)# setting(to,subject)
    pre {
      text = event:attr("text") || ""
    }
    email:send_text(to,subject,text) setting(response)
    fired {
      raise test_email event "message_sent" attributes response
    }
  }
  rule handleResponse {
    select when test_email message_sent
    fired {
      ent:lastResponse := event:attrs
    }
  }
}
