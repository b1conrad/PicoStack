ruleset org.picostack.get_me_ribs {
  meta {
    name "ribs_on_menus"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares ribs_on_menu, settings, id
  }
  global {
    event_domain = "org_picostack_get_me_ribs"
    get_lunch_menu = function(dt){
      date_only = dt.split("T").head().split("-").join("")
      url = "https://dining-services-batch-495348054234.s3-us-west-2.amazonaws.com/dining/Cannon/" + date_only
      response = http:get(url)
      ok = response{"status_code"} == 200
      lunch = ok => response{"content"}.decode()[1] | {}
      ok => lunch{"categories"} | []
    }
    has_fav_food = function(menu){
      fav_food_name = function(ans,fav){
        itemRE = ("\\b"+fav{"regx"}.uc()).as("RegExp")
        item_name = fav{"name"}
        interesting_item = function(answer, menu_item) {
	  answer || menu_item{"name"}.uc().match(itemRE)
        }
        has_food = menu.reduce(function(answer, map) {
	  answer || map{"menu_items"}.reduce(interesting_item, false)
        }, false)
        ans || (has_food => item_name | "")
      }
      ent:fav_foods.values().reduce(fav_food_name,"") // item_name of first favorite food found
    }
    summary_text = function(found_fav_food){
      food_name = found_fav_food || ent:fav_foods.keys().join(" or ")
      <<Today's Menu #{found_fav_food => "Has" | "Does Not Have"} #{food_name}>>
    }
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
      lunch_categories = date_to_check.get_lunch_menu()
      ok = lunch_categories.length()
      found_fav_food = lunch_categories.has_fav_food()
      real_food = function(mi) {mi{"header"} == false}
      summary = ok => found_fav_food.summary_text()
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
<h2 class="#{found_fav_food => "has_ribs" | "no_ribs"}">#{summary}</h2>
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
      base_url = <<#{meta:host}/sky/event/#{meta:eci}>>
      x_url = <<#{base_url}/experiment/#{event_domain}/new_wanted_item>>
      test_url = <<#{base_url}/test/#{event_domain}/it_is_morning>>
      thu_url = <<#{base_url}/test/#{event_domain}/it_is_Thursday_morning>>
      del_url = <<#{base_url}/del/#{event_domain}/item_not_wanted>>
      morning_url_on = <<#{base_url}/activate/#{event_domain}/morning_notification_wanted>>
      morning_url_off = <<#{base_url}/deactivate/#{event_domain}/no_morning_notification>>
      is_morning_event = function(s){
                           s{["event","domain"]} == event_domain &&
                           s{["event","name"]} == "it_is_morning"
                         }
      morning_event = schedule:list().filter(is_morning_event).head()
      toggle_url = morning_event => morning_url_off+"?id="+morning_event{"id"} | morning_url_on
      toggle_label = morning_event => "Turn off" | "Turn on"
      html:header("settings for ribs_on_menus",styles,null,null,_headers)
      + <<
<h1>Settings</h1>
<h2>Favorite food items:</h2>
<form action="#{x_url}">
<table>
<tr>
<th>Item name</th>
<th>Word starting with</th>
<th>Action</th>
</tr>
#{
      ent:fav_foods.values().map(function(v,i){
        <<
<tr>
<td>#{v{"name"}}</td>
<td>#{v{"regx"}}</td>
<td>#{i => <<<a href="#{del_url}?item_name=#{v{"name"}}">del</a> >> | "del"}</td>
</tr>
>>
      }).join("")
}
<tr>
<td><input name="item_name" required></td>
<td><input name="item_pattern" required pattern="[a-z][a-z]+" title="lower-case"></td>
<td><button type="submit">add</button></td>
</tr>
</table>
</form>
<button onclick="location='ribs_on_menu.html'">Done</button>
<h2>Morning notification</h2>
<h3>Active?</h3>
<p>#{
  morning_event => "Yes" | "No"
}
<button onclick="location='#{toggle_url}'">#{toggle_label}</button>
</p>
<p>
<button onclick="location='#{test_url}'">Test</button>
to look for favorite foods and if found send notification now.
</p>
<p>
<button onclick="location='#{thu_url}'">Test</button>
to pretend it is Thursday.
</p>
>>
      + html:footer()
    }
    id = function(){
      ent:id
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
  rule initializeEntityVar {
    select when org_picostack_get_me_ribs factory_reset
    if ent:fav_foods.isnull() then noop()
    fired {
      ent:fav_foods := {"Ribs":{"name":"Ribs","regx":"rib"}}
    }
  }
  rule addWantedItem {
    select when org_picostack_get_me_ribs new_wanted_item
      item_name re#(.+)#
      item_pattern re#([a-z][a-z]+)#
      setting(item_name,item_pattern)
    pre {
      new_item = {"name":item_name,"regx":item_pattern}
    }
    fired {
      ent:fav_foods{item_name} := new_item
      raise org_picostack_get_me_ribs event "settings_changed" attributes event:attrs
    }
  }
  rule delUnwantedItem {
    select when org_picostack_get_me_ribs item_not_wanted
      item_name re#(.+)#
      setting(item_name)
    if ent:fav_foods >< item_name then noop()
    fired {
      clear ent:fav_foods{item_name}
      raise org_picostack_get_me_ribs event "settings_changed" attributes event:attrs
    }
  }
  rule checkEveryMorning {
    select when org_picostack_get_me_ribs it_is_morning
    pre {
      menu = time:now().get_lunch_menu()
      found_fav_food = menu.has_fav_food()
    }
    if found_fav_food then noop()
    fired {
      raise byname_notification event "status" attributes {
        "application": meta:rid,
	"subject": "Cannon Has " + found_fav_food,
	"description": "Found " + found_fav_food.lc() + " on the menu today!"
      }
      raise org_picostack_get_me_ribs event "it_is_Thursday_morning"
        if time:strftime(time:now(),"%a")=="Thu"
    }
  }
  rule checkNextWeek {
    select when org_picostack_get_me_ribs it_is_Thursday_morning
    pre {
      found_fav_food = 4.range(8)
        .map(function(v){
            date = time:add(time:now(),{"days":v})
            menu = date.get_lunch_menu()
            fav_food = menu.has_fav_food()
            fav_food => time:strftime(date, "%A, %d %b %Y") + ": " + fav_food
                      | null
          })
        .filter(function(s){s})
    }
    if found_fav_food.length() then noop()
    fired {
      raise byname_notification event "status" attributes {
        "application": meta:rid,
	"subject": "Cannon will have favorite foods next week",
	"description": found_fav_food.join(";\n")
      }
    }
  }
  rule redirectBack {
    select when org_picostack_get_me_ribs settings_changed
             or org_picostack_get_me_ribs it_is_morning
             or org_picostack_get_me_ribs it_is_Thursday_morning
             or org_picostack_get_me_ribs morning_notification_wanted
             or org_picostack_get_me_ribs no_morning_notification
    pre {
      main_url = <<#{meta:host}/c/#{meta:eci}/query/#{meta:rid}/settings.html>>
    }
    send_directive("_redirect",{"url":main_url})
  }
  rule activateMorningNotification {
    select when org_picostack_get_me_ribs morning_notification_wanted
    fired {
      schedule org_picostack_get_me_ribs event "it_is_morning"
        repeat << 0 15 * * 1-5 >>  attributes { } setting(id)
      ent:id := id
    }
  }
  rule deactivateMorningNotification {
    select when org_picostack_get_me_ribs no_morning_notification
      id re#(.+)# setting(id)
    schedule:remove(id)
    fired {
      clear ent:id if ent:id == id || ent:id{"id"} == id
    }
  }
}
