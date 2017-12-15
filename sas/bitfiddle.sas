options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: bitfiddle.sas
  *
  *  Summary: Demo of shifting twiddling bits.
  *
  *  Adapted: Wed 04 Jun 2003 15:46:34 (Bob Heckel -- Rick Aster Shortcuts)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  format bitfield shifted BINARY32.;
  /* decimal 16,711,850 */
  bitfield = input('00000000111111110000000010101010', BINARY32.);
  /* Right shift so 16,711,850/2 = 8,355,925 */
  /* Another shift would mean div by 4, yet another would be div by 8... */
  shifted = brshift(bitfield, 7);
  put bitfield= / +1 shifted=;
run;
