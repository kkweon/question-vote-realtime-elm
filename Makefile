make:
	npm run build
serve:
	npm start
clean:
	rm -rf build/
gh-page: make
	ghp-import build/ --push
