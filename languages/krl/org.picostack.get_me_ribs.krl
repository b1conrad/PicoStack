ruleset org.picostack.get_me_ribs {
  meta {
    name "ribs_on_menus"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares ribs_on_menu, settings
  }
  global {
    event_domain = "org_picostack_get_me_ribs"
    ribs_on_menu = function(_headers, days_in_future){
      styles = <<
	<style>
	  .header {font-weight:bold;list-style-type:none;padding-top:0.5em;margin-left:-1.5em;}
	  h2 span {font-size:75%;font-weight:lighter;}
	  .content {padding-left:1.5em;}
	  .has_ribs {color: green;}
	  .no_ribs {color: red;}
	</style>
>>
      nav_url = <<#{meta:host}/c/#{meta:eci}/query/#{meta:rid}/ribs_on_menu.html?days_in_future=>>
      day_to_add = days_in_future.as("Number") || 0
      date_to_check = time:add(time:now(), {"days": day_to_add || 0})
      display_date = time:strftime(date_to_check , "%A, %d %b %Y")
      today = date_to_check.split("T").head().split("-").join("")
      url = "https://dining-services-batch-495348054234.s3-us-west-2.amazonaws.com/dining/Cannon/" + today
      response = http:get(url)
      ok = response{"status_code"} == 200
      lunch = ok => response{"content"}.decode()[1] | {}
      lunch_categories = ok => lunch{"categories"} | []
      itemRE = ent:item_pattern.defaultsTo("rib").uc().as("RegExp")
      item_name = ent:item_name.defaultsTo("Ribs")
      interesting_item = function(answer, menu_item) {
	answer => answer | menu_item{"name"}.uc().match(itemRE)
      }
      has_ribs = lunch_categories.reduce(function(answer, map) {
	answer => answer | map{"menu_items"}.reduce(interesting_item, false)
      }, false)
      real_food = function(mi) {mi{"header"} == false}
      summary = ok => <<Today's Menu #{has_ribs => "Does" | "Does Not"} Have #{item_name}>>
                    | "NO DATA"
      html:header("manage ribs_on_menus",styles,null,null,_headers)
      + <<
<h1
  style="float:right;cursor:pointer"
  title="Settings"
  onclick="location='settings.html'">⚙</h1>
<div class="content">
<h1>Cannon Center Lunch for #{display_date}</h1>
<a href="#{nav_url}#{day_to_add - 1}">Prior Day</a> 
#{ok && day_to_add < 10 => <<<a href="#{nav_url}#{day_to_add + 1}">Next Day</a> >> | ""}
<h2 class="#{has_ribs => "has_ribs" | "no_ribs"}">#{summary}</h2>
  #{lunch_categories.map(function(v) {
    <<
<h2>#{v{"name"}} <span>(#{v{"menu_items"}.filter(real_food).length()} items)</span></h2> 
<ul>
#{v{"menu_items"}.map(function(mi) {
  <<
    <li#{mi{"header"} => << class="header">> | ""}>#{mi{"name"}}</li>
  >>
}).join("")
}
</ul>
>>
}).join("")
  }
</div>
>>
      + html:footer()
    }
    settings = function(_headers){
      styles = <<
<style type="text/css">
table {
  border: 1px solid black;
  border-collapse: collapse;
}
td, th {
  border: 1px solid black;
  padding: 5px;
}
</style>
>>
      fav_foods = ent:fav_foods || [{"name":ent:item_name,"regx":ent:item_pattern}]
      x_url = <<#{meta:host}/sky/event/#{meta:eci}/experiment/#{event_domain}/new_wanted_item>>
      html:header("settings for ribs_on_menus",styles,null,null,_headers)
      + <<
<h1>Settings</h1>
<form action="#{x_url}">
<table>
<tr>
<th>Item name</th>
<th>Item pattern</th>
<th>Action</th>
</tr>
#{
      fav_foods.map(function(v,i){
        <<
<tr>
<td>#{v{"name"}}</td>
<td>#{v{"regx"}}</td>
<td>#{i => "" | "del"}</td>
</tr>
>>
      }).join("")
}
<tr>
<td><input name="item_name" required></td>
<td><input name="item_pattern" required pattern="[a-z]+" title="lower-case"></td>
<td><button type="submit">add</button></td>
</tr>
</table>
<h2>Experimental</h2>
<form action="#{x_url}">
It may not be ribs!
Name your favorite food
<input type="text" name="item_name" value="Ribs" required>
and say what to search for in the menu items
<input type="text" name="item_pattern" value="rib" required pattern="[a-z]+" title="lower-case">,
then click
<button type="submit">Submit</button>.
</form>
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
  rule changeWantedItem {
    select when org_picostack_get_me_ribs new_wanted_item
      item_name re#(.+)#
      item_pattern re#(.+)#
      setting(item_name,item_pattern)
    pre {
      its_ribs = item_name == "Ribs" && item_pattern == "rib"
    }
    if not its_ribs then noop()
    fired {
      ent:item_name := item_name
      ent:item_pattern := item_pattern
    } else {
      clear ent:item_name
      clear ent:item_pattern
    }
    finally {
      raise org_picostack_get_me_ribs event "settings_changed" attributes event:attrs
    }
  }
  rule redirectBack {
    select when org_picostack_get_me_ribs new_wanted_item
    pre {
      main_url = <<#{meta:host}/c/#{meta:eci}/query/#{meta:rid}/ribs_on_menu.html>>
    }
    send_directive("_redirect",{"url":main_url})
  }
}
