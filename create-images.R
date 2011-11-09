# Generate graphs from files git-get-stats.sh generated.
# Sami Kerola <kerolasa@iki.fi>

# Load libraries.
library('lattice')
library('gplots')

# Read data.
commiters <- read.table(header=T, file='committers.dat', sep='|')
dateLines <- read.csv(header=T, file='dates-lines.dat')
fileChanges <- read.table(header=T, file='file-changes.dat')
tags <- read.csv(header=T, file='tags.dat')

# Monthly commits
barplot(table(format(as.Date(dateLines$date), format="%m")),
	main="Monthly commits")


# Commit history per month
readline(prompt = "Pause. Press <Enter> to continue...")
commitHistory <- table(format(strptime(dateLines$date, "%Y-%m-%d %H:%M:%S"),
	format="%Y/%m"))
plot(commitHistory, ylab="commits", main="commit history")
lines(filter(commitHistory, rep(1/3, 3)), col='red', lwd=2)


# Commits heatmap
readline(prompt = "Pause. Press <Enter> to continue...")
# for some reason this does not print out when the file is sourced,
# simply copy pasting the lines bellow to R prompt does the trick.
hourlyActivity <- format((strptime("1970-01-01", "%Y-%m-%d", tz="CET") +
	(0:167 * 3600)), format="%u/%H")
hourlyMatrix <- matrix(table(c(format(strptime(
	dateLines$date, "%Y-%m-%d %H:%M:%S"),
	format="%u/%H"), hourlyActivity)), 24) - 1
# The strange `t(apply(t' stuff is here to flip day numbering from
# Mon to Sun up to down.  By default Mon = 1 ..  Sun = 7, and as the
# origin is at left bottom that messes the plot unless you flip.
levelplot(t(apply(t(hourlyMatrix), 2, rev)), 
	col.regions=colorpanel(19, "white", "black"),
	ylab='weekday', xlab='hour',
	main="commits during week")
