library(tercen)
library(dplyr)
library(fuzzyjoin)

options("tercen.workflowId" = "d330322c43363eb4f9b27738ef0042b9")
options("tercen.stepId"     = "aa0a455d-7b7d-496e-a3d8-b261a8d233eb")

ctx = tercenCtx()

# if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

documentId <- ctx$cselect()[[1]]
# documentId <- "9dae8351fb327013bbe5ae22d600fa54"
client = ctx$client
schema = client$tableSchemaService$get(documentId)

# empty list() on column names will return all columns
gff_table = as_tibble(client$tableSchemaService$select(schema$id, list(), 0, schema$nRows))
gff_table

gff_table <- gff_table[gff_table$feature == "gene", ]

chromosome <- ctx$rselect(ctx$rnames[[1]])[[1]] %>% as_tibble
names(chromosome) <- "chromosome"
start <- end <- ctx$rselect(ctx$rnames[[2]])[[1]] %>% as.numeric() %>% as_tibble
names(start) <- "start"
names(end) <- "end"
vcf_keys <- bind_cols(chromosome, start, end) %>% mutate(.ri = 1:nrow(.) - 1)

df_joined <- genome_left_join(vcf_keys, gff_table, by = c("chromosome", "start", "end"))
df_joined %>% 
  ctx$addNamespace() %>%
  ctx$save()
  