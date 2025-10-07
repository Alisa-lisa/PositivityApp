build-local:
	-rm -r build/app/outputs/apk/release/
	flutter build apk --release
	flutter install
