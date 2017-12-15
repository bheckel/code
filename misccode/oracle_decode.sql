DECODE(checkmefield, ifcheckmeisthis, thenuseme, elseuseme)
DECODE(checkmefield, ifcheckmeisthis, thenuseme, [more pairs], elsenomatchuseme)

SELECT symbol, DECODE(earnings, 0, NULL, price / earnings)
