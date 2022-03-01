#!/bin/bash
echo "Content-type: text/html"
echo
echo -n 1 >>../../tallies
COUNT=`cat ../../tallies | wc -c`
cat <<ENDMARKER
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>
<head>
<title>Contrivance without conclusion</title>
<meta name="format-detection" content="telephone=no">
</head>
<body>
<h1>Con without con</h1>
<h2>Contrivance without conclusion</h2>
<p>This page has been visited $COUNT times.</p>
<p>Latest visit from IP $REMOTE_ADDR on $(date).</p>
<p>Sample program from
<a href="http://conwithoutcon.blogspot.com/2014/05/contrivance-without-conclusion.html"
 target="_BLANK">Contrivance without conclusion</a>.</p>
</body>
</html>
ENDMARKER
