ruleset org.picostack.greeting {
  meta {
    name "greetings"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares greeting
  }
  global {
    event_domain = "org_picostack_greeting"
    greeting = function(_headers){
      action_url = <<#{meta:host}/sky/event/#{meta:eci}/callme/#{event_domain}/new_name_preference>>
      html:header("manage greetings","",null,null,_headers)
      + <<
<h1>Manage greetings</h1>
<p>Hello, #{ent:name.defaultsTo("world")}!</p>
>>
      + (ent:name.isnull() => <<
<p>How would you like to be greeted?</p>
<form action="#{action_url}">
I would like to be called <input name="name">.<br>
<button type="submit">Submit</button>
</form>
>> | "")
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["greetings"],
        {"allow":[{"domain":"org_picostack_greeting","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_greeting event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_greeting factory_reset
    foreach wrangler:channels(["greetings"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule recordNamePreference {
    select when org_picostack_greeting new_name_preference
      name re#(.+)# setting(new_name)
    fired {
      ent:name := new_name
      raise org_picostack_greeting event "name_preference_changed"
        attributes event:attrs
    }
  }
  rule redirectBack {
    select when org_picostack_greeting name_preference_changed
    pre {
      referer = event:attr("_headers").get("referer")
    }
    if referer then send_directive("_redirect",{"url":referer})
  }
}
