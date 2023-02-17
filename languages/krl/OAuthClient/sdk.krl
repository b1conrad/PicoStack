ruleset sdk {
  meta {
    provides takeAction
  }
  global {
    ClientID = meta:rulesetConfig{"ClientID"}
    ClientSecret = meta:rulesetConfig{"ClientSecret"}
    api_url = "https://example.com/api/"
    tokenValid = function(){
      tokenTime = ent:issued
      ttl = ent:token{"expires_in"} - 60 // with a minute to spare
      expiredTime = time:add(tokenTime,{"seconds":ttl})
      ent:token{"access_token"} && (expiredTime > time:now())
    }
    hdrs = function(){
      {
        "Content-Type":"application/json",
        "Authorization":"Bearer "+ent:token{"access_token"}
      }
    }
    takeAction = defaction(){
      url = api_url + "action"
      http:put(url,headers=hdrs()) setting(response)
      return response
    }
  }
  rule checkForValidToken {
    select when sdk might_need_a_valid_token
    if not tokenValid() then noop()
    fired {
      raise sdk event "new_token_needed"
    }
  }
  rule generateNewToken {
    select when sdk new_token_needed
    pre {
      creds = {
        "username":ClientID,
        "password":ClientSecret,
      }
      data = {"grant_type":"client_credentials"}
    }
    http:post(api_url+"token",auth=creds,form=data) setting(response)
    fired {
      ent:latestResponse := response
      ent:token := response{"status_code"}==200 => response{"content"}.decode()
                                                 | null
      ent:issued := time:now()
    }
  }
}
