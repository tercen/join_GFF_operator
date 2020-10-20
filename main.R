library(tercen)
library(dplyr)
library(fuzzyjoin)
library(IRanges)

ctx = tercenCtx()


documentId <- ctx$cselect()[[1]]
client = ctx$client
schema = client$tableSchemaService$get(documentId)

# empty list() on column names will return all columns
gff_table = as_tibble(client$tableSchemaService$select(schema$id, list(), 0, schema$nRows))

gff_table <- gff_table[gff_table$feature == "gene", ]
gff_table$start <- as.numeric(gff_table$start)
gff_table$end <- as.numeric(gff_table$end)

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
