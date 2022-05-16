ruleset fav-color-history {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module html
    shares index
  }
  global {
    index = function(){
      html:header("Favorite Color History","")
      + <<
<h1>Favorite Color History</h1>
<p>Your favorite color history:</p>
<table style="background-color:white">
  <thead>
    <tr>
      <th scope="col">Date</th>
      <th scope="col">Name</th>
      <th scope="col">RGB hex</th>
      <th scope="col">Swatch</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>#{time:now()}</td>
      <td style="text-align:center"><code>#{ent:colorname}</code></td>
      <td><code>#{ent:colorcode}</code></td>
      <td style="background-color:#{ent:colorname}"></td>
    </tr>
  </tbody>
</table>
>>
      + html:footer()
    }
    channel_tags = [
      "fav-color-history",
    ]
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        channel_tags,
        {"allow":[{"domain":"fav_color","name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise fav_color event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when fav_color factory_reset
    foreach wrangler:channels(channel_tags).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule recordFavColor {
    select when fav_color fav_color_selected
      fav_color re#^(\#[a-f0-9]{6})$# setting(fav_color)
    pre {
      colorname = colors:colormap()
        .filter(function(v){v==fav_color})
        .keys()
        .head()
      || "unknown"
    }
    fired {
      ent:colorname := colorname
      ent:colorcode := fav_color
    }
  }
  rule redirectBack {
    select when fav_color fav_color_selected
    pre {
      referrer = event:attr("_headers").get("referer") // sic
    }
    if referrer then send_directive("_redirect",{"url":referrer})
  }
}
