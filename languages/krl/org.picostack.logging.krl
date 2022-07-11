ruleset org.picostack.logging {
  meta {
    name "logs"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares log
  }
  global {
    event_domain = "org_picostack_logging"
    log = function(_headers){
      html:header("manage logs","",null,null,_headers)
      + <<
<h1>Manage logs</h1>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["logs"],
        {"allow":[{"domain":"org_picostack_logging","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_logging event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_logging factory_reset
    foreach wrangler:channels(["logs"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}
