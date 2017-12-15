
data _null_;
  array x[*] $10 ('tweedledum' 'tweedledee' 'baboon' 'baby' 'humpty');
  call sortc(of x[*]);
  put +3 x[*];
run;
