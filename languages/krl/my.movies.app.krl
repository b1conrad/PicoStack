ruleset my.movies.app {
  meta {
    name "movies"
    use module io.picolabs.wrangler alias wrangler
    use module html
    shares genres
  }
  global {
    event_domain = "my_movies_app"
    genres = function(){
      html:header("movie genres","")
      + <<
<h1>Movie genres</h1>
<form action="genre.html">
<select name="genre" required autofocus>
  <option value="">choose a genre</option>
#{ent:genres.map(function(g){
  <<  <option value="#{g.get("id")}">#{g.get("name")}</option>
>>}).join("")}
</select>
<button type="submit">See movies</button>
</form>
<p>This product uses the TMDb API but is not endorsed or certified by <a href="https://www.themoviedb.org/">TMDb</a>.</p>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["movies"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise my_movies_app event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when my_movies_app factory_reset
    foreach wrangler:channels(["movies"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
  rule saveAPIkey {
    select when my_movies_app factory_reset
    fired {
      ent:api_key := ctx:rid_config{"api_key"}
      raise my_movies_app event "new_api_key" attributes event:attrs
    }
  }
  rule getMovieGenres {
    select when my_movies_app new_api_key
    pre {
      the_url = "https://api.themoviedb.org/3/genre/movie/list?api_key="
      response = http:get(the_url+ent:api_key)
      the_genres = response.get("content").decode().get("genres")
    }
    fired {
      ent:genres := the_genres
      raise my_movies_app event "new_genres" attributes event:attrs
    }
  }
}
