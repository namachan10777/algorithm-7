set HERE (cd (dirname (status --current-filename)); pwd)

cd $HERE

dub run

for script in ./scripts/*.txt
	gnuplot $script
end

mkdir -p fig

for eps in *.eps
	mv $eps ./fig/
end

for csv in *.csv
	rm $csv
end
