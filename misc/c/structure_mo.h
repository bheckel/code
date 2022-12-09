/* This is not mentioned in any externs. */
struct nest {
  int imp;
  /* char car[] won't work. */
  char car[80];
};

/* Set up template. */
struct monthtag {
  char name[9];
  char abbrev[4];
  int days;
  int monum;
  struct nest bird;
}; 
  
struct monthtag mystruct[4] = {
              {
               "january",
               "jan",
               31,
               111
              },

              {
               "february",
               "feb",
               28,
               222
              },

              {
               "march",
               "mar",
               31,
               333,
               {11, "two"}
              }
};
