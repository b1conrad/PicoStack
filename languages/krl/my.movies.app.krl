ruleset my.movies.app {
  meta {
    name "movies"
    use module io.picolabs.wrangler alias wrangler
    use module html
    use module org.themoviedb.sdk alias tmdb
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
  rule getMovieGenres {
    select when my_movies_app factory_reset
    fired {
      ent:genres := tmdb:genre_movie_list()
      raise my_movies_app event "new_genres" attributes event:attrs
    }
  }
}
