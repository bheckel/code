
-- Update every row in the Rep_AcctWalk_CurrentMnth table
UPDATE Rep_AcctWalk_CurrentMnth currMnth
SET (Business_L1, Business_L2, Business_L3,
     Business_L4, Business_Segment ) = 
        (SELECT Business_L1, 
                Business_L2,
                Business_L3,
                Business_L4,
                Business_Segment 
           FROM PSME.Glob.List_BusOrg busOrg
          WHERE trim( currMnth.bus_code ) = busOrg.busCode)


-- Only update rows where there is a match (could also use MERGE INTO ... WHEN MATCHED THEN UPDATE SET )
UPDATE Rep_AcctWalk_CurrentMnth currMnth
SET (Business_L1, Business_L2, Business_L3,
     Business_L4, Business_Segment ) = 
        (SELECT Business_L1, 
                Business_L2,
                Business_L3,
                Business_L4,
                Business_Segment 
           FROM PSME.Glob.List_BusOrg busOrg
          WHERE trim( currMnth.bus_code ) = busOrg.busCode)
 WHERE EXISTS( SELECT 1
                 FROM PSME.Glob.List_BusOrg busOrg
                WHERE trim( currMnth.bus_code ) = busOrg.busCode )
