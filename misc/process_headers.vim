" Process column headers to conform with SAS 32 byte max
" :so process_headers.vim
" :se columns=33
:%substitute/ \+/_/g
:%substitute/	//g
:%substitute/(//g
:%substitute/)//g
:%substitute/_#//g
:%substitute/_\+ / /g
:%substitute/\.//g
:%substitute/_-_/_/g
:%substitute/-/_/g
:%substitute/%/Pct/g
:%substitute/\//_/g
:%substitute/://g
:%substitute/,//g
:%substitute/_\{2,}/_/g
:%substitute/$/ :\$40./g
:%substitute/$/                                              \/* @ *\//g
