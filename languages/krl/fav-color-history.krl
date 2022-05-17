ruleset fav-color-history {
  meta {
    use module io.picolabs.wrangler alias wrangler
    use module html
    shares index
  }
  global {
    makeMT = function(ts){
      MST = time:add(ts,{"hours": -7});
      MDT = time:add(ts,{"hours": -6});
      MDT > "2022-11-06T02" => MST |
      MST > "2022-03-13T02" => MDT |
                               MST
    }
    ts_format(ts){
      parts = ts.split(re#[T.]#)
      parts.filter(function(v,i){i<2}).join(" ")
    }
    history_rows = function(){
      history_one_row = function(v,k){
        the_name = v{"colorname"}
        the_code = v{"colorcode"}
        <<    <tr>
      <td>#{k.makeMT().ts_format()}</td>
      <td style="text-align:center"><code>#{the_name}</code></td>
      <td><code>#{the_code}</code></td>
      <td#{the_code => << style="background-color:#{the_name}">> | ""}></td>
    </tr>
>>
      }
      ent:history.map(history_one_row).values().join("")
    }
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
#{history_rows()}</tbody>
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
      ent:history := {}
      raise fav_color_history event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when fav_color_history factory_reset
    foreach wrangler:channels(channel_tags).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule recordInstallation {
    select when fav_color factory_reset
    fired {
      ent:history{time:now()} := {
        "colorname": "none",
        "colorcode": null,
      }
    }
  }
  rule recordFavColor {
    select when fav_color fav_color_recorded
      colorname re#(.+)#
      colorcode re#(.+)#
      setting(colorname,colorcode)
    fired {
      ent:history{time:now()} := {
        "colorname": colorname,
        "colorcode": colorcode,
      }
    }
  }
}
