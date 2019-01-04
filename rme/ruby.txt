DBI install in ~/src:

tar xvfz dbi-0.1.1.tar.gz 
cd ruby-dbi/
ruby setup.rb config --with=dbi,dbd_oracle
ruby setup.rb setup
ruby setup.rb install
