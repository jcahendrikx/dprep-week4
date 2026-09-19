# Exercise 7
all: output/creator_top10_week4.csv

temp/creator_week4.csv: src/build_temp.R data/video_view.csv data/creators.csv
	Rscript src/build_temp.R

output/creator_top10_week4.csv: src/build_output.R temp/creator_week4.csv
	Rscript src/build_output.R

clean:
	rm -f temp/*.csv output/*.csv