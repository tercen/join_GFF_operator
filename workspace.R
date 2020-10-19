library(tercen)
library(dplyr)
library(fuzzyjoin)

options("tercen.workflowId" = "d330322c43363eb4f9b27738ef0042b9")
options("tercen.stepId"     = "aa0a455d-7b7d-496e-a3d8-b261a8d233eb")

ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

documentId <- ctx$cselect()[[1]]
documentId <- "9dae8351fb327013bbe5ae22d600fa54"
client = ctx$client
schema = client$tableSchemaService$get(documentId)

# empty list() on column names will return all columns
gff_table = as_tibble(client$tableSchemaService$select(schema$id, list(), 0, schema$nRows))
gff_table

library(fuzzyjoin)

chr <- ctx$rselect(ctx$rnames[[1]]) %>% as_tibble
names(chr) <- "chr"
pos <- ctx$rselect(ctx$rnames[[2]]) %>% as_tibble
names(pos) <- "pos"
vcf_keys <- bind_cols(chr, pos) %>% mutate(.ri = 1:nrow(.) - 1)


df_out <- vcf_keys %>%
  fuzzy_join(gff_table, by = c("chr" = "chromosome", "pos" = "start", "pos" = "end"), 
             match_fun = list(`==`, `>=`, `<`)) %>% 
  ctx$addNamespace() %>%
  ctx$save()
  