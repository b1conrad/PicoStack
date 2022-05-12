ruleset css2colors {
  meta {
    provides colormap, options
  }
  global {
    colors = { // scraped from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/color_keywords May 11, 2022
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
    colormap = function(){
      colors
    }
    options = function(indent,default){
      left_margin = indent || ""
      gen_option = function(v,k){
        <<#{left_margin}<option value="#{v}"#{k==default => " selected" | ""}>#{k}</option>
>>
      }
      colors.map(gen_option).values().join("")
    }
  }
}
