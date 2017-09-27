
load.packages <- c("ggplot2", "data.table")
new.packages <- load.packages[!(load.packages %in% installed.packages()[,"Package"])]
if(length(new.packages) > 0) install.packages(new.packages)

library('data.table')
library('ggplot2')

anno = commandArgs(trailingOnly = T)

if(length(anno) < 1){
  message("Usage: Rscript homerAnnoStats.R <peaks.anno>")
  stop("Missing input file.")
}

homer.anno = data.table::fread(anno[1])
colnames(homer.anno)[1] = 'peakid'
homer.anno$anno = sapply(strsplit(x = as.character(homer.anno$Annotation), split = ' (', fixed = T), '[[', 1)

homer.anno = homer.anno[,.(Chr, Start, End, Strand, anno, `Gene Name`, `Gene Type`,`Distance to TSS`, `Nearest PromoterID`, `Nearest Ensembl`)]
homer.anno = homer.anno[order(anno, `Gene Name`)]
colnames(homer.anno) = c('Chr', 'Start', 'End', 'Strand', 'Annotation', 'Hugo_Symbol', 'Biotype', 'Distance_to_TSS', 'Nearest_PromoterID', 'Nearest_Ens')
homer.anno$Annotation = gsub(pattern = "3' UTR", replacement = '3pUTR', x = homer.anno$Annotation)
homer.anno$Annotation = gsub(pattern = "5' UTR", replacement = '5pUTR', x = homer.anno$Annotation)

homer.anno.stat = as.data.frame(table(homer.anno$anno))
homer.anno.stat$fract = homer.anno.stat$Freq/sum(homer.anno.stat$Freq)*100
colnames(homer.anno.stat)[1] = 'anno'

g =ggplot(data = homer.anno, aes(x = '', fill = Annotation))+geom_bar(width = 1)+coord_polar(theta = 'y')+
  theme_minimal(base_size = 12)+ggtitle(label = "Peak distribution", subtitle = paste0("Peaks: ", nrow(homer.anno)))+
  scale_fill_manual(values = c('3pUTR' = '#E7298A', '5pUTR' = '#D95F02', 'Intergenic' = '#BEBADA',
                               'TTS' = '#FB8072', 'exon' = '#80B1D3', 'intron' = '#FDB462', 'non-coding' = '#FFFFB3',
                               'NA' = 'gray70', 'promoter-TSS' = '#1B9E77'))+xlab("")+ylab("")

write.table(homer.anno, paste(anno, 'tsv', sep='.'), quote = F, row.names = F, sep='\t')

pdf(file = paste(anno, '.pdf', sep=''), width = 5, height = 5, paper = 'special', bg = "white")
print(g)
dev.off()
#write.table(homer.anno.stat, paste(anno, '_stat.tsv', sep=''), quote = F, row.names = F, col.names = T, sep='\t')
