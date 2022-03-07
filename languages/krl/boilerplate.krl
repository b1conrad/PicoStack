ruleset boilerplate {
  meta {
    name "boilerplates"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares boilerplate
  }
  global {
    logout = function(_headers){
      ctx:query(
        wrangler:parent_eci(),
        "byu.hr.oit",
        "logout",
        {"_headers":_headers}
      )
    }
    boilerplate = function(_headers){
      url = logout(_headers).extract(re#location='([^']*)'#).head()
      html:header("manage boilerplates","",url,null,_headers)
      + <<
<h1>Manage boilerplates</h1>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["boilerplates"],
        {"allow":[{"domain":"boilerplate","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise boilerplate event "factory_reset"
    }
  }
}
