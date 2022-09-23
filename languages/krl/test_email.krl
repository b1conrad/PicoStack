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
      ent:lastResponse{"content"}
    }
  }
  rule firstEmail {
    select when test_email first_email
    email:send() setting(response)
    fired {
      ent:lastResponse := response
    }
  }
}
