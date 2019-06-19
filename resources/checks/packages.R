arguments <- commandArgs(T)
related <- as.character(arguments[1])

message("Checking R version")

currentr <- paste0(R.Version()['major'], ".", R.Version()['minor'])
ch <- compareVersion(currentr, "3.4")
if(ch == -1)

{
	stop("You are running R version ", currentr, ". Please upgrade to at least 3.4.0.")
}

message("Checking that all required packages are present")

pkglist <- c(
	"lmtest",
	"sandwich",
	"data.table"
)

index <- pkglist %in% rownames(installed.packages())
if(any(!index))
{
	stop("Before continuing, the following packages need to be installed:\n", paste(pkglist[!index], collapse="\n"))
}

