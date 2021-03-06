library(packdep)

## hacked version of related.packages that allows
##  for restriction to in- or out- connections
newdep <- function (x, order = 1, node, mode="all", plot.it=TRUE) 
{
    if (!is(x, "igraph")) 
        stop("'x' must be an object of class 'igraph'.")
    if (is.character(node) && length(node) == 1) {
        if (node %in% V(x)$name) 
            target <- which(V(x)$name==node)
        else stop("unknown package ", node)
    }
    else {
        stop("'node' must be a character string , the name of a package.")
    }
    s = make_ego_graph(x, order, target,mode=mode)[[1]]
    V(s)$color = "SkyBlue2"
    V(s)[V(s)$name == node]$color = "red"
    if (plot.it) plot(s, vertex.label = V(s)$name, layout = layout.kamada.kawai(s))
    return(s)
}

## general-purpose "apply across combinations of multiple lists"
xapply <- function(FUN,...,FLATTEN=TRUE,MoreArgs=NULL) {
  ## add progress bar??
  L <- list(...)
  inds <- do.call(expand.grid,lapply(L,seq_along)) ## Marek's suggestion
  retlist <- vector("list",nrow(inds))
  for (i in 1:nrow(inds)) {
    arglist <- mapply(function(x,j) x[[j]],L,as.list(inds[i,]),SIMPLIFY=FALSE)
    if (FLATTEN) {
      retlist[[i]] <- do.call(FUN,c(arglist,MoreArgs))
    }
  }
  retlist
}

d <- map.depends()
## dr <- map.depends(contriburl=contrib.url("http://r-forge.r-project.org"))

gsize <- function(x) x[[1]]  ## nodes in a graph
tmpf <- function(x,node,order) {
    gsize(newdep(x,order=order,node=node,mode="out",plot.it=FALSE))
}
dd <- expand.grid(repos=c("CRAN"),pkg=c("nlme","lme4"),order=1:3)
dd$number <- unlist(xapply(tmpf,
                           list(d),list("nlme","lme4"),as.list(1:3)))

library(ggplot2); theme_set(theme_bw())
ggplot(dd,aes(order,number,colour=pkg,lty=repos,shape=repos))+
    geom_point()+geom_line()+
        theme_bw()+scale_x_continuous(breaks=1:3)+
            scale_y_log10()

png("lme4dep1.png",1200,1200)
invisible(ss <- newdep(d,1,"lme4",mode="out"))
dev.off()
##plot(ss,layout=layout_with_sugiyama,hgap=2,vgap=2)
##L <- 
##coords <- with_sugiyama(hgap=2,vgap=2)
##plot(ss,layout=coords)
#######################

