
RAID (redundant array of independent disks) is a way of storing the 
same data in different places (thus, redundantly) on multiple hard 
disk. By placing data on multiple disks, I/O operations can overlap 
in a balanced way, improving performance. Since multiple disks 
increases the mean time between failure (MTBF), storing data 
redundantly also increases fault-tolerance. 

A RAID appears to the operating system to be a single logical hard 
disk. RAID employs the technique of striping, which involves 
partitioning each drive's storage space into units ranging from 
a sector (512 bytes) up to several megabytes. The stripes of all 
the disks are interleaved and addressed in order. 

In a single-user system where large records, such as medical or 
other scientific images, are stored, the stripes are typically set 
up to be small (perhaps 512 bytes) so that a single record spans 
all disks and can be accessed quickly by reading all disks at the 
same time. 

In a multi-user system, better performance requires establishing a 
stripe wide enough to hold the typical or maximum size record. This 
allows overlapped disk I/O across drives. 

There are at least nine types of RAID plus a non-redundant array (RAID-0): 

* RAID-0. This technique has striping but no redundancy of data. It 
 offers the best performance but no fault-tolerance. 
* RAID-1. This type is also known as disk mirroring and consists of at 
 least two drives that duplicate the storage of data. There is no 
 striping. Read performance is improved since either disk can be read 
 at the same time. Write performance is the same as for single disk 
 storage. RAID-1 provides the best performance and the best 
 fault-tolerance in a multi-user system. 
* RAID-2. This type uses striping across disks with some disks storing 
 error checking and correcting (ECC) information. It has no advantage 
 over RAID-3. 
* RAID-3. This type uses striping and dedicates one drive to storing 
 parity information. The embedded error checking (ECC) information is 
 used to detect errors. Data recovery is accomplished by calculating 
 the exclusive OR (XOR) of the information recorded on the other drives. 
 Since an I/O operation addresses all drives at the same time, RAID-3 
 cannot overlap I/O. For this reason, RAID-3 is best for single-user 
 systems with long record applications. 
* RAID-4. This type uses large stripes, which means you can read records 
 from any single drive. This allows you to take advantage of overlapped 
 I/O for read operations. Since all write operations have to update the 
 parity drive, no I/O overlapping is possible. RAID-4 offers no advantage 
 over RAID-5. 
* RAID-5. This type includes a rotating parity array, thus addressing the 
 write limitation in RAID-4. Thus, all read and write operations can 
 be  overlapped. RAID-5 stores parity information but not redundant data 
 (but parity information can be used to reconstruct data). RAID-5 requires 
 at least three and usually five disks for the array. It's best for multi- 
 user systems in which performance is not critical or which do few write 
 operations. 
* RAID-6. This type is similar to RAID-5 but includes a second parity 
 scheme that is distributed across different drives and thus offers 
 extremely high fault- and drive-failure tolerance. There are few or   
 no commercial examples currently. 
* RAID-7. This type includes a real-time embedded operating system as 
 a controller, caching via a high-speed bus, and other characteristics 
 of a stand-alone computer. One vendor offers this system. 
* RAID-10. This type offers an array of stripes in which each stripe is 
 a RAID-1 array of drives. This offers higher performance than RAID-1 but 
 at much higher cost. 
* RAID-53. This type offers an array of stripes in which each stripe is a 
 RAID-3 array of disks. This offers higher performance than RAID-3 but at 
 much higher cost. 
