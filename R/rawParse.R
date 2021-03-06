#' Parsing the data to get top expressed genes
#'
#' This function loads the count data as a dataframe. It assumes that each line
#' contains gene expression profile of one single cell, and each column
#' contains the one single gene expression profile in different cells. The dataframe
#' should also contain the cell type information with column name 'cell_type'.
#' Group information should also be included as 'compare_group' if users want
#' to call differntial expressed ligand-receptor pairs. Batch information as
#' 'batch' is optional. If included, users may want to use the raw count data
#' for later analysis.
#'
#' @param data Input data, raw or normalized count with 'cell_type' column
#' @param top_genes (scale 1 to 100) Top percent highly expressed genes used
#' to find ligand-receptor pairs, default is 50
#' @param stats Whether calculates the mean or the median of the data. Available
#' options are 'mean' and 'median'.
#' @importFrom progress progress_bar
#' @return A dataframe of the data
#' @export
rawParse<-function(data,top_genes=50,stats='mean'){
  res=NULL
  cell_group<-unique(data$cell_type)
  pb <- progress::progress_bar$new(total = length(cell_group))
  pb$tick(0)
  for(i in cell_group){
    sub_data<-data[data$cell_type==i,]
    counts<-t(subset(sub_data,select=-cell_type))
    counts<-apply(counts,2,function(x) {storage.mode(x) <- 'numeric'; x})
    if(stats=='mean'){
      temp<-data.frame(rowMeans(counts),i,stringsAsFactors = FALSE)
    }else if(stats=='median'){
      temp<-data.frame(apply(counts, 1, FUN = median),i,stringsAsFactors = FALSE)
    }else{
      print('error stats option')
    }
    temp<-temp[order(temp[,1],decreasing=TRUE),]
    temp<-temp[1:ceiling(nrow(temp)*top_genes/100),]
    temp<-temp %>% tibble::rownames_to_column()
    res<-rbind(res,temp)
    pb$tick()
  }
  colnames(res)<-c('gene','exprs','cell_type')
  return(res)
}
