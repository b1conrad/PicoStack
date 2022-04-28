ruleset first_jsp2 {
  meta {
    shares hello
  }
  global {
    hello = function(){
      num = random:number(0,1)
      msg = num > 0.95 => "You'll have a lucky day!"
                        | "Well, life goes on ... "
      <<<!DOCTYPE html>
<html>
  <head lang="en">
    <title>First JSP/KRL</title>
  </head>
  <body>
    <h2>#{msg}</h2>
    <p>(#{num})</p>
    <a href="hello.html"><h3>Try Again</h3></a>
  </body>
</html>
>>
    }
  }
}
