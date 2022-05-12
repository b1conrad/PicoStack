ruleset fav-color-sample {
  meta {
    name "fav-color"
    use module io.picolabs.wrangler alias wrangler
    use module html
    use module css2colors alias colors
    shares index
  }
  global {
    index = function(_headers){
      url = <<#{meta:host}/sky/event/#{meta:eci}/selectcolor/fav_color/fav_color_selected>>
      html:header("Favorite Color","",null,null,_headers)
      + <<
<h1>Favorite Color</h1>
#{ent:colorname => <<<p>Your favorite color:</p>
<table style="background-color:white">
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">RGB hex</th>
      <th scope="col">Swatch</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center"><code>#{ent:colorname}</code></td>
      <td><code>#{ent:colorcode}</code></td>
      <td style="background-color:#{ent:colorname}"></td>
    </tr>
  </tbody>
</table>
>> | <<<p>You have not yet selected a favorite color.</p>
>>}<hr>
<form action="#{url}" method="POST">
Favorite color: <select name="fav_color">
#{colors:options("  ",ent:colorname)}</select>
<button type="submit">Select</button>
</form>
>>
      + html:footer()
    }
    channel_tags = [
      "fav-color-sample",
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
