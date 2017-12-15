#!/usr/bin/perl -w
##############################################################################
#     Name: update_mysql_db.pl
#
#  Summary: Modify the Known Master db to correct records that are missing 
#           or coded wrongly.  Each time the db is reloaded, the bad data will
#           overwrite these corrections so it's important to run this prior to
#           running any of the query*.pl scripts.
#
#  Created: Tue 10 Sep 2002 13:07:48 (Bob Heckel)
##############################################################################
use strict qw(refs vars);
use DBI();
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 0;
###use constant DBASE      => 'indocc';
use constant TBLNAME    => 'iando';

###my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
###                       "bqh0", 
###                       "",     # MySQL pw
###                       {'RaiseError' => 0}  # keep going on failure
###                      );
##################Config##########################

my $dbh = DBI->connect($connect_str, $user, $pw, \%perr);

# Make sure these are in the Known db:
# OK if they fail b/c alreaady there. 
# Per Instruction Manual Pt. 19 (pg. 59) Rules:
#               dummy, dummy, dummy, indlit, olit, inum, onum, len of ilit+olit 
InsertAndOrUpdate('RETIRED SCHOOL TEACHER', 'RETIRED SCHOOL TEACHER', 786, 231, $dbh); 
InsertAndOrUpdate('', 'BOOKKEEPER', 728, 512, $dbh); 
InsertAndOrUpdate('', 'CARPENTER', 77, 623, $dbh); 
InsertAndOrUpdate('', 'SECRETARY', 759, 570, $dbh); 
InsertAndOrUpdate('CIVIL SERVICE', 'CIVIL SERVICE WORKER', 939, 536, $dbh); 
InsertAndOrUpdate('DEPOT', 'EMPLOYEE', 959, 586, $dbh); 
InsertAndOrUpdate('DEPOT', '', 959, 586, $dbh); 
InsertAndOrUpdate('DIET CENTER', '', 818, 990, $dbh); 
InsertAndOrUpdate('LUMBER', 'LOGGER', 27, 613, $dbh); 
InsertAndOrUpdate('MANUFACTURING', 'TOOL & DIE MAKER', 399, 813, $dbh); 
InsertAndOrUpdate('OFFICE', 'OFFICE WORKER', 778, 586, $dbh); 
InsertAndOrUpdate('RR', 'RR ENGINEER', 608, 920, $dbh); 
InsertAndOrUpdate('DOES NOT APPLY', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('NOT APPLICABLE', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('NONE', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('NO', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('N.A.', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('N/A', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('DOMESTIC', 'DOMESTIC', 929, 423, $dbh); 
InsertAndOrUpdate('DOMESTIC', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOMEMAKER', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOMEMAKER', '', 989, 901, $dbh); 
InsertAndOrUpdate('HOMEMAKER', 'HOME MAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOME MAKER', 'HOME MAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOME MAKER', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('SELF-EMPLOYED', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('SELF EMPLOYED', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOME', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOMES', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('OWN HOME', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('OWN HOME', 'HOME MAKER', 989, 901, $dbh); 
InsertAndOrUpdate('IN HER OWN HOME', 'HOME MAKER', 989, 901, $dbh); 
InsertAndOrUpdate('IN HER OWN HOME', 'HOMEMAKER', 989, 901, $dbh); 
InsertAndOrUpdate('HOUSEWIFE', 'HOUSEWIFE', 989, 901, $dbh); 
InsertAndOrUpdate('', 'HOUSEWIFE', 989, 901, $dbh); 
InsertAndOrUpdate('HOUSEWIFE', '', 989, 901, $dbh); 
InsertAndOrUpdate('HEALTH CARE', 'DOCTOR', 809, 306, $dbh); 
InsertAndOrUpdate('HEALTH CARE', 'NURSE', 809, 313, $dbh); 
InsertAndOrUpdate('HEALTH CARE', 'REGISTERED NURSE', 809, 313, $dbh); 
InsertAndOrUpdate('HEALTH CARE', 'OFFICE MANAGER', 809, 500, $dbh); 
InsertAndOrUpdate('SEWING', 'SEAMSTRESS', 888, 835, $dbh); 
InsertAndOrUpdate('SELF-EMPLOYED', '', 999, 43, $dbh); 
InsertAndOrUpdate('SELF EMPLOYED', '', 999, 43, $dbh); 
InsertAndOrUpdate('', 'SELF-EMPLOYED', 999, 43, $dbh); 
InsertAndOrUpdate('', 'SELF EMPLOYED', 999, 43, $dbh); 
InsertAndOrUpdate('WIRE', '', 399, 910, $dbh); 
InsertAndOrUpdate('INFANT', '', 989, 910, $dbh); 
InsertAndOrUpdate('', 'INFANT', 989, 910, $dbh); 
InsertAndOrUpdate('CHILD', '', 989, 910, $dbh); 
InsertAndOrUpdate('', 'CHILD', 989, 910, $dbh); 
# SELF EMPLOYED as Ind With Occ:
InsertAndOrUpdate('SELF EMPLOYED', 'C.P.A.', 728, 80, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CPA', 728, 80, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ABSTRACTER', 727, 215, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ACCOUNTANT', 728, 80, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ACTUARY', 739, 120, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AERONAUTICAL ENGINEER', 729, 132, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ALTERATIONIST', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ALUMINUM SIDING INSTALLER', 77, 623, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ANESTHESIOLOGIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'APARTMENT HOUSE MANAGER', 707, 41, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ARBORIST', 777, 160, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ARCHITECT', 729, 130, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ARTIFICIAL FLOWER MAKER', 398, 775, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ARTIST, COMMERCIAL', 737, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ARTIST, MEDICAL', 737, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ATTORNEY', 727, 210, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AUCTIONEER', 778, 496, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AUDITOR', 728, 80, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AUTHOR', 856, 285, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AUTHORS AGENT', 856, 50, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'AUTO PAINTER', 877, 881, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BABY-SITTER, HOME OF OTHERS', 929, 460, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BABY-SITTER, OWN HOME', 847, 460, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BAKER', 119, 780, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BARBER', 897, 450, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BARTENDER', 869, 404, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BASKET MAKER', 387, 854, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BEAUTICIAN', 898, 451, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BEAUTY OPERATOR', 898, 451, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BIOCHEMIST', 739, 161, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BLACKSMITH', 887, 762, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BOARDING CHILDREN', 829, 460, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BONDSMAN', 909, 95, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BOOKKEEPER', 728, 512, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BREAD MAKER', 119, 780, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'BRICKLAYER', 77, 622, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CABINETMAKER, REPAIR', 888, 850, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CAKE MAKER', 119, 780, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CARPENTER', 77, 623, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CARTOONIST', 856, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CATERER', 868, 401, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CERAMIST', 247, 896, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CERTIFIED PUBLIC ACCOUNTANT', 728, 80, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHAIR CANER', 888, 775, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHEMICAL ENGINEER', 729, 135, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHINA PAINTER', 856, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHIROPODIST', 808, 312, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHIROPRACTOR', 799, 300, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CHOREOGRAPHER', 856, 274, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CIVIL ENGINEER', 729, 136, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CLOTHING ALTERATIONIST', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'COMMERCIAL ARTIST', 737, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'COURT REPORTER', 759, 215, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CROP DUSTER', 29, 903, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CUSTOM COMBINER', 29, 605, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'CUSTOM TAILOR', 168, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DANCING TEACHER', 789, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DENTAL HYGIENIST', 808, 331, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DENTAL LABORATORY TECHNICIAN', 818, 876, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DENTAL MECHANIC', 818, 876, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DENTAL SURGEON', 798, 301, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DENTIST', 798, 301, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DERMATOLOGIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DETECTIVE', 768, 382, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DIAMOND SETTER', 519, 875, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DIETITIAN', 808, 303, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DISC JOCKEY', 856, 280, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DOCTOR', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DRESS ALTERATIONIST', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DRESSMAKER CUSTOM', 168, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DRUG DEALER', 569, 495, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DRUGGIST', 507, 305, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'EFFICIENCY EXPERT', 739, 143, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ELDERLY CARE GIVER', 817, 461, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ELECTRICAL CONTRACTOR', 77, 620, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ELECTRICAL ENGINEER', 729, 141, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ELECTRICIAN', 77, 635, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ELECTROLOGIST', 899, 451, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ENTOMOLOGIST', 739, 160, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'EXTERMINATOR', 769, 424, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FAMILY COUNSELOR', 837, 201, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FISHERMAN', 28, 610, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FISHING', 28, 610, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FLOOR WAXER', 769, 422, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FORTUNE TELLER', 909, 276, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FOSTER MOTHER', 829, 460, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'FURNITURE REPAIRMAN', 888, 850, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GARDENER', 777, 425, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GENEALOGIST', 909, 186, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GEOLOGIST', 739, 174, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GLASS ARTIST', 249, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GLASS STAINER', 249, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GROCER', 497, 470, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'GROCERY CARRIER', 909, 962, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HAIRDRESSER', 898, 451, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HAIRSTYLIST', 898, 451, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HOME ECONOMIST', 739, 255, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HOROLOGIST', 338, 743, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HORTICULTURIST', 739, 160, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HOUSE PAINTER', 77, 642, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HOUSECLEANING', 929, 423, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HUCKSTER', 569, 495, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'HUSTLER', 569, 495, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INDIAN BLANKET WEAVER', 148, 841, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INDUSTRIAL ENGINEER', 729, 143, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INSURANCE AGENT, MANAGE OFFICE', 699, 481, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INTERIOR DESIGN', 737, 263, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'DECORATING', 737, 263, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INVENTOR', 739, 176, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'INVESTMENT COUNSELOR', 697, 85, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'IRONER', 929, 831, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'IVORY CARVER', 398, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'JANITOR', 769, 420, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'JEWELER', 519, 470, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'JOURNALIST', 856, 281, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'KNITTER', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LANDSCAPE ARCHITECT', 729, 130, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LAUNDRESS', 929, 830, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LAWN MOWER', 777, 425, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LAWYER', 727, 210, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LEATHER CARVER', 179, 871, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LECTURER', 856, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LINOLEUM LAYER', 77, 624, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LIVESTOCK DEALER', 448, 51, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LOCKSMITH', 768, 754, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'LOG CUTTER', 27, 613, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MANAGEMENT CONSULTANT', 739, 71, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MANICURIST', 899, 452, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MARRIAGE COUNSELOR', 837, 200, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MECHANIC', 877, 720, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MECHANICAL ENGINEER', 729, 146, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MEDICAL PRACTICE', 797, 353, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MERCHANT POLICE', 768, 392, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'METALLURGICAL ENGINEER', 729, 145, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MIDWIFE', 808, 365, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MILLWRIGHT', 77, 736, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MINING ENGINEER', 729, 150, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MODEL', 856, 490, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MORTICIAN', 908, 32, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MUSIC COMPOSER', 856, 275, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MUSIC TEACHER', 789, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'MUSICIAN', 856, 275, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NATUROPATH', 808, 326, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NEUROLOGIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NOTARY PUBLIC', 727, 593, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NUMISMATIST', 558, 240, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NUTRITIONIST', 808, 303, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OBSTETRICIAN', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OCCUPATIONAL THERAPIST', 808, 315, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OCULIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OPHTHALMOLOGIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OPTOMETRIST', 807, 304, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ORAL SURGEON', 798, 301, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ORTHODONTIST', 798, 301, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'ORTHOPEDIC SURGEON', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'OSTEOPATH', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PAINTER', 77, 642, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PAINTER, ARTIST', 856, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PAINTING CONTRACTOR', 77, 620, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PAPERHANGER', 77, 643, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PARTY PLANNING AND DECORATING', 909, 263, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PATHOLOGIST', 797, 165, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PATIENT SITTER', 817, 360, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PAWNBROKER', 689, 470, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PEDDLER', 569, 495, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PEDIATRICIAN', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PEDIATRIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PERIODONTIST', 798, 301, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PHARMACIST', 507, 305, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PHYSICAL THERAPIST', 808, 316, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PHYSICIAN', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PHYSICIST', 739, 170, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PIANO TEACHER', 789, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PIANO TUNER', 888, 743, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PIE BAKER', 119, 780, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PIMP', 909, 465, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PLASTERER', 77, 646, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PLOWING GARDENS', 29, 960, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PLUMBER', 77, 644, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PLUMBING CONTRACTOR', 77, 620, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PODIATRIST', 808, 312, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PRACTICAL NURSE', 758, 350, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PRIVATE DUTY NURSE', 758, 313, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PRIVATE DUTY NURSE, PRACTICAL', 758, 350, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PRIVATE DUTY NURSE, REGISTERED', 758, 313, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PROCESS SERVER', 727, 522, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PROFESSIONAL NURSE', 808, 313, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PROSTITUTE', 909, 465, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PSYCHIATRIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PSYCHOANALYST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PSYCHOTHERAPIST', 808, 182, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PUBLIC SPEAKER', 856, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'PUBLIC STENOGRAPHER', 759, 593, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'QUILTER', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'RADIO MECHANIC', 879, 702, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'RADIO REPAIRMAN', 879, 702, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'RADIOLOGIST', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'RAG COLLECTOR', 428, 896, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REAL ESTATE AGENT', 707, 492, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REAL ESTATE APPRAISER', 707, 81, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REALTOR', 707, 492, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REGISTERED NURSE', 808, 313, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REPORTER, NEWS', 856, 281, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'NEWS REPORTER', 856, 281, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'REPORTER, STENOGRAPHY', 759, 523, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SALESPERSON', 579, 476, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SEAMSTRESS', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SENIOR CITIZEN CARE GIVER', 817, 360, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SERVICE STATION MANAGER', 509, 470, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SHOE REPAIRMAN', 889, 833, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SIGN PAINTER', 747, 881, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SKIN SEWER', 398, 832, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SPORTS INSTRUCTOR', 789, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'SURGEON', 797, 306, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TAILOR AND CLEANER', 907, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TAX CONSULTANT', 728, 94, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TAXICAB DRIVER', 619, 914, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TAXIDERMIST', 856, 260, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TELEVISION MECHANIC', 879, 712, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TELEVISION REPAIRMAN', 879, 712, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TEXTILE DESIGNER', 737, 263, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TEXTILE REWEAVER', 888, 835, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'THERAPIST', 808, 324, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'THRESHER', 29, 605, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TIRE REPAIRER', 877, 726, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TITLE SEARCHER', 727, 215, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TOURIST GUIDE', 859, 455, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TRASH COLLECTOR', 779, 972, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TREE SURGEON', 777, 425, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TRUCK DRIVER', 617, 913, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'TUTOR', 789, 234, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'UNDERTAKER', 908, 32, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'UPHOLSTERER', 888, 845, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'VENDOR', 569, 495, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'VETERINARIAN', 748, 325, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'VETERINARY', 748, 325, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WASHERWOMAN', 929, 830, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WATCHMAKER', 888, 743, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WEAVER', 148, 841, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WELDER', 887, 814, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WINDOW CLEANER', 769, 422, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WINDOW DRESSER', 747, 263, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WOODSMAN', 27, 613, $dbh);
InsertAndOrUpdate('SELF EMPLOYED', 'WRITER', 856, 285, $dbh);
# Errors in Known Master db discovered by hand:
###InsertAndOrUpdate('COMPUTER PROGRAM', 'MANAGER', 738, 011, $dbh); 
###InsertAndOrUpdate('COMPUTER PROGRAMMER', 'MANAGER', 738, 011, $dbh); 

$dbh->disconnect();

exit 0;


# Want to make sure that 1- this pair is in the db at all and 2- if it is, the
# I&O codes are the same as these.  There have been errors on the "reviewed"
# list used to create the Known db.
sub InsertAndOrUpdate { 
  my ($ilit, $olit, $inum, $onum, $dbhandle) = @_;

  my $ilen = length $ilit;
  my $olen = length $olit;
  my $totlen = $ilen + $olen;

  my $sthandle = $dbhandle->prepare("UPDATE " . TBLNAME . 
                                    " SET indnum = ?, occnum = ?" .
                                    " WHERE indliteral = ? AND occliteral = ?;");

  # OK to fail (unique ilit & olit concat records only allowed in db) if it
  # already exists.  But if it exists, make sure inum & onum are correct.
  $dbhandle->do("INSERT INTO " . TBLNAME . " 
            VALUES (999, 99, 999, 
                " . $dbhandle->quote($ilit) . ",
                " . $dbhandle->quote($olit) . ", 
                $inum, $onum, $totlen)"
           ) or $sthandle->execute($inum, $onum, $ilit, $olit)
             and warn "Record already exists.  THIS IS NOT A PROBLEM\n\n";
           # TODO add global? counter

  return 0;
}
