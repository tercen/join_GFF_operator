library(tercen)
library(dplyr)
library(fuzzyjoin)

ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

documentId <- ctx$cselect()[[1]]
client = ctx$client
schema = client$tableSchemaService$get(documentId)

gff_table = as_tibble(client$tableSchemaService$select(schema$id, list(), 0, schema$nRows))

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
