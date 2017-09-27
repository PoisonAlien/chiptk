# chiptk
optimized protocols for processing 50-bp SE ChIP-seq

## Introduction
chiptk is a set of optimized protocols for ChIP-seq read-alignment, peak calling with MACS2 and fast Super Enhancer identification via bwtool.

### align
Uses `bwa` aligner for alignment. Few parameters are hardcoded which are found to work best for 50 bp SE reads. Also does removes (not marks) duplicates via picard.

```
---------------------------------------------------------------------------------------------------------------------------------------------------
usage: chiptk align [options] <picard> <output_fn> <Reference> <foo.fq.gz>

wrapper around bowtie and picard MarkDcuplicate. Bowtie alignment parameters are optimized for 50 bp single end reads.
bowtie -> picard

positional arguments:
  picard       path to picard jar file
  output_fn    Basename for output file. Ususally sample name.
  bowtie_idx   Bowtie index file for reference genome. Required.
  fq           Fastq file (gz compressed). Required.

optional arguments:
  -D           Output directory to store results. Optional. Default ./bams
  -t           threads to use. Default 4.
  -k           report up to <int> good alignments per read (default: 2)
  -n           max mismatches in seed (can be 0-3, default: -n 2)
  -m           suppress all alignments if > <int> exist (default: 2)

Example: align picard.jar foo hg19 foo.fq.gz
---------------------------------------------------------------------------------------------------------------------------------------------------
```

### macspeaks
wrapper around macs2 callpeak. Also converts bedGraphs to bigWig following input signal subtraction. Uses hard-coded value of 200bp as the fragment size for read extension.
```
---------------------------------------------------------------------------------------------------------------------------------------------------
usage: chiptk macspeaks [options] <hg19.chrom.sizes> <input.bam> <chip.bam>

positional arguments:
  chromSizes   path to chromosome sizes. Can be obtained using UCSC fetchChromSizes.sh script.
  chip.bam     ChIP bam - Required.
  input.bam    Input bam - Required.

optional arguments:
  -D           Output directory to store results. Optional. Default ./macs_op
  -o           Basename for output file. Ususally sample name. Default parses from chip.bam
  -f           Format of Input file, AUTO, BED or ELAND or ELANDMULTI or ELANDEXPORT or SAM or BAM or BOWTIE or BAMPE or BEDPE
  -g           Effective genome size. Default hs. (can be mm, ce, dm)
  -q           Minimum FDR (q-value) cutoff for peak detection. Deafult 0.01
  -b           call broad peaks. Default false.

Example: macspeaks hg19.chrom.sizes KOCebpeInput.bam KOCebpe.bam
---------------------------------------------------------------------------------------------------------------------------------------------------
```

### SE 
Identify SuperEnhancers using BigWig files instead of BAM files. (Usaually from H3K27Ac or H3K4Me1 pulldown)
ROSE which uses BAM files for signal extraction is emabarrisingly slow. Using bw files with bwtools can achieve this within minutes.

```
---------------------------------------------------------------------------------------------------------------------------------------------------
Usage: chiptk SE [options] <rose> <peaks> <input> <chip>

positional arguments:
  rose  path to 'ROSE_callSuper.R' Rscript. This comes as a part of ROSE software
  peaks Input enhancer peaks.
  bwc   BigWig sample for Control. Input
  bwt   BigWig sample for Treatment. ChIP

optional arguments:
  -m    Distance to merge closely spaced peaks in bps. Default 12000.
  -D    Output directory to store results. Optional. Default ./SE
  -o    Basename for output file. Ususally sample name. Default parses from bwt

Example: SE ROSE_callSuper.R H3K27Ac_peaks.narrowPeak H3K27Ac_control.bw H3K27Ac_treat.bw
---------------------------------------------------------------------------------------------------------------------------------------------------
```

## Summarize homer annotations
`homerAnnoStats.R` a tiny R script which summarizes peak annotations generated with homer `annotatePeaks.pl`, also a generates a pie chart of peak distributions.

```r
Rscript homerAnnoStats.R <peaks.anno>
```