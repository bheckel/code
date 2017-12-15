if ( argc == 2 ) {
  if ( !strcmp(argv[1], "-h") ) {
    fprintf(stderr, "Usage: %s <message>\nBeeps and optionally prompts "
                    "user then returns button value.\n", argv[0]);
    exit(1);
  }
}

/* or */

if ( argc != 2 ) {
  fprintf(stderr,"usage: %s hostname\n", argv[0]);
  exit(__LINE__);
}  
