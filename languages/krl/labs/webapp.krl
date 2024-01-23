ruleset webapp {
  meta {
    use module temperature_store alias ts
    shares index
  }
  global {
    index = function(){
      temps = ts:temperatures()
      temps_count = temps.keys().length()
      temps_text = 
        temps_count == 0 => "No readings"             |
        temps_count == 1 => "One reading"             |
                            temps_count + " readings"
      viols = ts:threshold_violations()
      viols_count = viols.keys().length()
      viols_text =
        viols_count == 0 => ""                                  |
        viols_count == 1 => ", with one violation"              |
                            ", with "+viols_count+" violations"
      <<<!DOCTYPE HTML>
<html>
  <head>
    <title>Wovyn sensors summary</title>
    <meta charset="UTF-8">
<style type="text/css">
body { font-family: "Helvetica Neue",Helvetica,Arial,sans-serif; }
</style>
  </head>
  <body>
<h1>Wovyn sensors summary</h1>
<p>#{temps_text}#{viols_text}.</p>
  </body>
</html>
>>
    }
  }
}
