#!/bin/sh

# Insert a header into first line of each mn_e file
for f in mn_e_*.htm; do mv $f $f.tmp && \
echo "
<html><body><head>
<style> 
	@font-face { font-family: verajjan; src: url('../Tinos-Regular.ttf'); }
	@font-face { font-family: verajjab; src: url('../Tinos-Bold.ttf'); }
	body{font-family:verajjan; background-color:white;}
	.title{font-family:verajjab; color:#5A5;font-weight:bold}
	div.title{font-size:150%; margin-top:24px;}
	.varc{font-size:60%; color:grey}
	.var{display:none; font-size: 100%; color:black; background-color:silver;}
	.pageno {font-size:60%; color:blue}
	.paratype06 {font-style:italic;color:#999999;}
	p[class*="paratype2"]{ margin: 0 0 0 24px;}
</style>
</head>" \
>$f.tmp2 && cat $f.tmp2 $f.tmp > $f && rm $f.tmp $f.tmp2; done
