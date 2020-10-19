# Join GFF operator

##### Description

The `join_GFF_operator` can be used to join a range-based GFF annotation file to position-based genomic data.

##### Usage

Input projection|.
---|---
`row1`           | character, chromosome name 
`row2`           | numeric/character, position on the chromosome 
`column`        | character, GFF table ID

Output relations|.
---|---
`join`        | joined tables

##### Details

Details on the computation.

##### See Also

[read_VCF_operator](https://github.com/tercen/read_VCF_operator)

