all:
	quarto render
	git add docs www

preview:

	quarto preview

clean:

	rm -rf docs

