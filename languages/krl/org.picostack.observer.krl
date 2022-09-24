ruleset org.picostack.observer {
  meta {
    name "observations"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    use module io.picolabs.subscription alias subs
    use module com.mailjet.sdk alias email
    shares observation
  }
  global {
    event_domain = "org_picostack_observer"
    observables = [
      "new relationship",
      "new connection",
      "new basicmessage",
      "new participant",
    ]
    observation = function(_headers){
      baseURL =<<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}>> 
      setURL = <<#{baseURL}/new_settings>>
      testURL = <<#{baseURL}/test_needed>>
      html:header("manage observations","",null,null,_headers)
      + <<
<h1>Manage observations</h1>
<p>You have #{ent:relationship_count} established relationships.</p>
<h2>Email Settings</h2>
<form action="#{setURL}">
<input type="checkbox" name="relationship events" checked disabled title="not implemented">
Relationship events
<br>
<input type="checkbox" name="weekly_summary" disabled title="not implemented">
Weekly summary only
<br>
To <input name="email">
<button type="submit">Save changes</button>
</form>
<h2>Technical</h2>
<form action="#{testURL}">
<input name="email">
<button type="submit">Test</button>
</form>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["observations"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_observer event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_observer factory_reset
    foreach wrangler:channels(["observations"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule initializeEntityVariables {
    select when org_picostack_observer factory_reset
             or byname_notification status
                  where event:attr("application") == "byu.hr.relate"
    pre {
      subs_count = subs:established()
        .filter(function(s){s{"Tx_role"}!="participant list"})
        .length()
    }
    fired {
      ent:relationship_count := subs_count
    }
  }
  rule saveSettings {
    select when org_picostack_observer new_settings
      email re#(.+@.+)# setting(to)
    fired {
      ent:email := to
    }
  }
  rule sendTestNotification {
    select when org_picostack_observer test_needed
      email re#(.+@.+)# setting(to)
      where ent:tt.isnull()
         || ent:tt > time:now().time:add({"minutes": 10})
    email:send_text(to,<<#{meta:rid} test message>>)
      setting(response)
    fired {
      ent:tt := time:now()
      ent:latestResponse := response
.klog("response")
    }
  }
  rule redirectBack {
    select when org_picostack_observer test_needed
             or org_picostack_observer new_settings
    pre {
      referrer = event:attr("_headers").get("referer") // sic
    }
    if referrer then send_directive("_redirect",{"url":referrer})
  }
  rule sendObservationNotification {
    select when byname_notification status
      application re#(.+)#
      subject     re#(.+)#
      description re#(.*)#
      setting(app,subj,descr)
      where ent:email && not ent:weekly_digest
    pre {
      subject = <<ByName: #{app}: #{subj}>>
    }
    email:send_text(ent:email,subject,descr) setting(response)
    fired {
      ent:latestResponse := response
.klog("response")
    }
  }
}
