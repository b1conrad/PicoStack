ruleset org.picostack.get_me_ribs {
  meta {
    name "ribs_on_menus"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares ribs_on_menu
  }
  global {
    event_domain = "org_picostack_get_me_ribs"
    ribs_on_menu = function(_headers){
      styles = <<
	<style>
	  h2 {color:green;font-weight:lighter;}
	</style>
>>
      html:header("manage ribs_on_menus",styles,null,null,_headers)
      + <<
<h1>Manage ribs_on_menus</h1>
<h2>hello world!</h2>
<pre>
	#{http:get("https://dining-services-batch-495348054234.s3-us-west-2.amazonaws.com/dining/Cannon/20221108").encode()}
</pre>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["ribs_on_menus"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_picostack_get_me_ribs event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_picostack_get_me_ribs factory_reset
    foreach wrangler:channels(["ribs_on_menus"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}
