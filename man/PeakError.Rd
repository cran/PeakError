\name{PeakError}
\alias{PeakError}
\title{PeakError}
\description{Compute true and false positive peak calls, with respect to a
database of annotated \code{regions}.}
\usage{PeakError(peaks, regions)}
\arguments{
  \item{peaks}{data.frame with columns chrom, chromStart, chromEnd. NOTE:
chromStart should be 0-based and chromEnd should be
1-based. EXAMPLE: the first 100 base of of a chromosome are
chromStart=0, chromEnd=100. The second 100 bases are
chromStart=100, chromEnd=200.}
  \item{regions}{data.frame with columns chrom, chromStart, chromEnd, annotation.}
}

\value{data.frame for each region with additional counts of true
positives (tp, possible.tp), false positives (fp, possible.fp,
fp.status), and false negatives (fn, fn.status).}

\author{Toby Dylan Hocking}




\examples{
x <- seq(5, 85, by=5)
peaks <- rbind(
  Peaks("chr2", x, x+3),
  Peaks("chr3", c(25, 38, 57), c(33, 54, 75)),
  Peaks("chr4", c(5, 32, 38, 65), c(15, 35, 55, 85)),
  Peaks("chr5", c(12, 26, 56, 75), c(16, 54, 59, 85)))
regions.list <- list()
for(chr in 1:5){
  regions.list[[chr]] <- data.frame(
    chrom=paste0("chr", chr),
    chromStart=c(10, 30, 50, 70),
    chromEnd=c(20, 40, 60, 80),
    annotation=c("noPeaks", "peakStart", "peakEnd", "peaks"))
}
regions <- do.call(rbind, regions.list)
err <- PeakError(peaks, regions)
ann.colors <- c(
  noPeaks="#f6f4bf",
  peakStart="#ffafaf",
  peakEnd="#ff4c4c",
  peaks="#a445ee")
if(require(ggplot2)){
  ggplot()+
    geom_rect(aes(
      xmin=chromStart+1/2, xmax=chromEnd+1/2,
      ymin=-1, ymax=1,
      fill=annotation,
      linetype=fn.status,
      size=fp.status),
      data=err, color="black")+
    scale_y_continuous("", breaks=NULL)+
    scale_linetype_manual(
      values=c("false negative"="dotted", correct="solid"))+
    scale_size_manual(
      values=c("false positive"=3, correct=1))+
    scale_fill_manual(
      values=ann.colors,
      breaks=names(ann.colors))+
    facet_grid(chrom ~ .)+
    theme_bw()+
    guides(
      fill=guide_legend(order=1),
      linetype=guide_legend(order=2, override.aes=list(fill="white")),
      size=guide_legend(order=3, override.aes=list(fill="white")))+
    theme(panel.margin=grid::unit(0, "cm"))+
    geom_segment(aes(
      chromStart+1/2, 1/2, xend=chromEnd+1/2, yend=1/2),
      data=peaks, color="deepskyblue", size=2)+
    scale_x_continuous(
      "position on chromosome",
      breaks=seq(10, 90, by=10))+
    geom_text(aes(
      base, -1/2, label="N"),
      data.frame(base=10:90),
      color="deepskyblue")
}
}
