set HERE (cd (dirname (status --current-filename)); pwd)

cd $HERE


mkdir -p fig
mkdir -p cache

dub run

for script in ./*.script
	gnuplot $script
	mv $script ./cache
end

for pdf in *.pdf
	mv $pdf ./fig/
end

for csv in *.csv
	mv $csv ./cache
end
