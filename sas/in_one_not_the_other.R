# http://www.cookbook-r.com/Manipulating_data/Comparing_data_frames/

dfA <- data.frame(Subject=c(1,1,2,2), Response=c("X","X","X","X"))
# Subject Response
#       1        X
#       1        X
#       2        X
#       2        X

dfB <- data.frame(Subject=c(1,2,3), Response=c("X","Y","X"))
# Subject Response
#       1        X
#       2        Y
#       3        X

dfC <- data.frame(Subject=c(1,2,3), Response=c("Z","Y","Z"))
# Subject Response
#       1        Z
#       2        Y
#       3        Z

dfA$Coder <- "A"
dfB$Coder <- "B"
dfC$Coder <- "C"

df <- rbind(dfA, dfB, dfC)
df <- df[c(3,1,2)]  # reorder


dupsBetweenGroups <- function (df, idcol) {
    # df: the data frame
    # idcol: the column which identifies the group each row belongs to

    # Get the data columns to use for finding matches
    datacols <- setdiff(names(df), idcol)

    # Sort by idcol, then datacols. Save order so we can undo the sorting later.
    sortorder <- do.call(order, df)
    df <- df[sortorder,]

    # Find duplicates within each id group (first copy not marked)
    dupWithin <- duplicated(df)

    # With duplicates within each group filtered out, find duplicates between groups. 
    # Need to scan up and down with duplicated() because first copy is not marked.
    dupBetween = rep(NA, nrow(df))
    dupBetween[!dupWithin] <- duplicated(df[!dupWithin,datacols])
    dupBetween[!dupWithin] <- duplicated(df[!dupWithin,datacols], fromLast=TRUE) | dupBetween[!dupWithin]

    # =================== Replace NA's with previous non-NA value =====================
    # This is why we sorted earlier - it was necessary to do this part efficiently

    # Get indexes of non-NA's
    goodIdx <- !is.na(dupBetween)

    # These are the non-NA values from x only
    # Add a leading NA for later use when we index into this vector
    goodVals <- c(NA, dupBetween[goodIdx])

    # Fill the indices of the output vector with the indices pulled from
    # these offsets of goodVals. Add 1 to avoid indexing to zero.
    fillIdx <- cumsum(goodIdx)+1

    # The original vector, now with gaps filled
    dupBetween <- goodVals[fillIdx]

    # Undo the original sort
    dupBetween[sortorder] <- dupBetween

    # Return the vector of which entries are duplicated across groups
    return(dupBetween)
}


dupRows <- dupsBetweenGroups(df,"Coder")

dupRows  # give single horizontal line, not useful

print("duplicated rows")
cbind(df, dup=dupRows)
#    Coder Subject Response   dup
# 1      A       1        X  TRUE
# 2      A       1        X  TRUE
# 3      A       2        X FALSE
# 4      A       2        X FALSE
# 5      B       1        X  TRUE
# 6      B       2        Y  TRUE
# 7      B       3        X FALSE
# 8      C       1        Z FALSE
# 9      C       2        Y  TRUE
# 10     C       3        Z FALSE

print("unique rows")
cbind(df, unique=!dupRows)
#    Coder Subject Response unique
#    1      A       1        X  FALSE
#    2      A       1        X  FALSE
#    3      A       2        X   TRUE
#    4      A       2        X   TRUE
#    5      B       1        X  FALSE
#    6      B       2        Y  FALSE
#    7      B       3        X   TRUE
#    8      C       1        Z   TRUE
#    9      C       2        Y  FALSE
#    10     C       3        Z   TRUE



# Ignoring any diffs in Subject:
dfNoSubj <- subset(df, select=-Subject)
dupRows <- dupsBetweenGroups(dfNoSubj,"Coder")
cbind(df, dup=dupRows)
