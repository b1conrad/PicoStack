ruleset org.themoviedb.sdk {
  meta {
    provides genre_movie_list
  }
  global {
    api_key = ctx:rid_config{"api_key"}
    genre_movie_list = function() {
      the_url = "https://api.themoviedb.org/3/genre/movie/list?api_key="
      response = http:get(the_url+api_key)
      response.get("content").decode().get("genres")
    }
  }
}

