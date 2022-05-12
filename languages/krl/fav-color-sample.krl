ruleset fav-color-sample {
  meta {
    name "fav-color"
    description <<
      scraped from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/color_keywords May 11, 2022
    >>
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
#{options("  ",ent:colorname)}</select>
<button type="submit">Select</button>
</form>
>>
      + html:footer()
    }
    options = function(indent,default){ // use from colors module when available
      left_margin = indent || ""
      gen_option = function(v,k){
        <<#{left_margin}<option value="#{v}"#{k==default => " selected" | ""}>#{k}</option>
>>
      }
      colormap.map(gen_option).values().join("")
    }
    colormap = {
      "black": "#000000",
      "silver": "#c0c0c0",
      "gray": "#808080",
      "white": "#ffffff",
      "maroon": "#800000",
      "red": "#ff0000",
      "purple": "#800080",
      "fuchsia": "#ff00ff",
      "green": "#008000",
      "lime": "#00ff00",
      "olive": "#808000",
      "yellow": "#ffff00",
      "navy": "#000080",
      "blue": "#0000ff",
      "teal": "#008080",
      "aqua": "#00ffff",
      "orange": "#ffa500",
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
      colorname = colormap.filter(function(v){v==fav_color}).keys().head()
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
