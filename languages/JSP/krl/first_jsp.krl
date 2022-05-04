ruleset first_jsp {
  meta {
    shares hello
  }
  global {
    hello = function(){
      num = random:number(0,1)
      requestURI = meta:host + "/sky/cloud/" + meta:eci + "/" + meta:rid + "/hello.html"
      <<<html>
<head><title>First JSP/KRL</title></head>
<body>
#{ (num > 0.95 => <<
  <h2>You'll have a lucky day!</h2><p>(#{num})</p>
>> | <<
  <h2>Well, life goes on ... </h2><p>(#{num})</p>
>>)}
  <a href="#{requestURI}"><h3>Try Again</h3></a>
</body>
</html>
>>
    }
  }
}
