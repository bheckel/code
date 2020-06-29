#!/bin/awk -f
# Adapted: Tue Sep 09 11:51:16 2003 (Bob Heckel --
# http://www.linuxjournal.com/article.php?sid=6677)

# Everything's global yeeech.

# TODO not working
function Usage() {
  print "Usage: MkInvoice <SalesFile> <ClientFile> <InvoiceFile>";
  exit(1);
}


function PrintHeader() {
  print "\n" > InvoiceFile;
  printf "            A P Building Supplies\n" > InvoiceFile;
  printf "            59 Hardware Avenue\n" > InvoiceFile;
  printf "            Hammerville\n" > InvoiceFile;
  printf "            2439\n\n\n" > InvoiceFile;
}


function PrintClient() {
  print CName > InvoiceFile;
  print CAdr1 > InvoiceFile;
  print CAdr2 > InvoiceFile;
  print CAdr3 > InvoiceFile;
  print CZip > InvoiceFile;
  print CTel > InvoiceFile;
}


function PrintInvHead() {
  printf "\n"  > InvoiceFile;
  printf "Stock Code  Item Bought    Qty  Unit Price  Total\n"  > InvoiceFile;
  printf "----------  -----------    ---  ----------  -----\n"  > InvoiceFile;
}


# TODO needs work
function PrintInvLine() {
  STotal = 0;
  STotal = SPrice * SQty;
  RTotal = RTotal + STotal;
  printf i"%10s\t%-19s\t%d\t%1.2f\t\t%5.2f\n",SCode,SDesc,SQty,SPrice,STotal \
                                                                > InvoiceFile; 
}


function PrintInvTot() {
  printf "                ------\n" > InvoiceFile;
  printf "                %5.2f\n\n", RTotal > InvoiceFile;
  printf "\f"  > InvoiceFile;
  RTotal = 0;
  InvTotFlag = 0;
  HeaderFlag = 0;
}


# Read a record from the Sales file If the end of file is reached or the file
# is not found, set EndSales to 1
function ReadSales() {
  FS=",";
  ###SalesStat = getline < SalesFile;
  ###if ( SalesStat > 0 )
  if ( getline < SalesFile ) {
    SCode = $1;
    SCId = $2;
    SQty = $3;
    SDesc = $4;
    SPrice = $5;
  } else {
    EOFSales = 1;
  }
}


function ReadClient() {
  FS="~";
  if ( getline < ClientFile ) {
    CName = $1;
    CId = $2;
    CAdr1 = $3;
    CAdr2 = $4; 
    CAdr3 = $5;
    CZip = $6;
    CTel = $7;
  } else {
    EOFClient = 1;
  }
}


BEGIN {
  InvTotFlag = 0;
  HeaderFlag = 0;
  EOFClient = 0;   
  EOFSales = 0;

  numparm = (ARGC -1);

  if ( numparm !=3 ) {
    Usage();
  } else {
    SalesFile = ARGV[1];
    ClientFile = ARGV[2];
    InvoiceFile = ARGV[3];
  }

  # Read a single record from each of the Sales and Client files.
  ReadClient();
  ReadSales();

  if ( EOFSales == 1 ) {
    print "Error! - Sales file NOT found!!";
    exit(1);
   }

  if ( EOFClient == 1 ) {
    print "Error! - Client file NOT found!!";
    exit(1);
  }

  # While not EOF
  while ( EOFSales == 0 ) {
    while ( ( SCId == CId ) && (EOFSales == 0) ) {
      if ( HeaderFlag == 0 ) {
        PrintHeader();
        PrintClient();
        PrintInvHead();
        HeaderFlag = 1;
        InvTotFlag = 1;
      } else {
        PrintInvLine();
        ReadSales();
      }
    }

  if ( InvTotFlag == 1 )
    PrintInvTot();

  ReadClient();

  if ( EOFClient == 1 )
    break;
  }
}
