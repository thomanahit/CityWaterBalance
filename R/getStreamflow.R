#' Gather time series of streamflow data
#' 
#' This function gathers daily average streamgauge data for a group of gauges
#' from USGS NWIS 
#'
#' @param start start date in format 'YYYY-MM-DD'
#' @param end end date in format 'YYYY-MM-DD'
#' @param gages list of USGS gauge numbers 
#' @return list of: 
#'  \item{sites}{list of gauge site names}
#'  \item{site_num}{list of gauge numbers}
#'  \item{flows}{xts of daily average discharge (cfs)}
#' @importFrom dataRetrieval readNWISdv
#' @importFrom xts as.xts 
#' @importFrom zoo as.zoo
#' @examples 
#' flow <- getStreamflow('2000-01-01', '2010-12-31', c('05551540', '05552500'))
#' @export

getStreamflow <- function(start, end, gages) {
    
    # initialize output lists
    flows <- list()
    sites <- list()
    sn <- list()
    
    # retrieve gauge data
    for (i in 1:length(gages)) {
        flow <- readNWISdv(gages[i], "00060", start, end)
        
        if (length(flow) > 0) {
            sites[i] <- attr(flow, "siteInfo")$station_nm
            sn[i] <- attr(flow, "siteInfo")$site_no
            colnames(flow) <- c("agency", "site", "date", "flow_cfs", 
                                "flow_code")
            flow <- as.xts(flow$flow_cfs, order.by = as.Date(flow$date))
            flows[[i]] <- flow
        }
    }
    
    if (length(gages) == 1) {
        f <- flows[[1]]
    }
    
    if (length(gages) > 1) {
        f <- cbind(flows[[1]], flows[[2]])
    }
    if (length(gages) > 2) {
        for (i in 3:length(gages)) {
            f <- cbind(f, flows[[i]])
        }
    }
    
    f[f == 0] <- NA
    names(f) <- sn
    
    return(list(sites = sites, site_num = sn, flows = f))
    
}
