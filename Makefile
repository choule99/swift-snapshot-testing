setup:

	brew bundle install
	brew upgrade
	brew cleanup
	brew autoremove
	mint bootstrap
	lefthook install

lint:

	mint run --no-install realm/SwiftLint  --config .swiftlint.yml --quiet

format:

	mint run --no-install nicklockwood/SwiftFormat . --config .swiftformat --quiet
	mint run --no-install realm/SwiftLint  --config .swiftlint.yml --fix --quiet

website-install:

	npm --prefix Website ci

website-preview:

	npm --prefix Website run dev

site-preview:

	npm --prefix Website run preview

website-check:

	npm --prefix Website run check

site-check: website-check

	npm --prefix Website run check:links

website-build:

	npm --prefix Website run build

documentation-build:

	mkdir -p docs/api
	swift package --allow-writing-to-directory docs/api/snapshottesting generate-documentation --target SnapshotTesting --output-path docs/api/snapshottesting --transform-for-static-hosting --hosting-base-path swift-snapshot-testing/api/snapshottesting
	swift package --allow-writing-to-directory docs/api/snapshotpreviews generate-documentation --target SnapshotPreviews --output-path docs/api/snapshotpreviews --transform-for-static-hosting --hosting-base-path swift-snapshot-testing/api/snapshotpreviews
	swift package --allow-writing-to-directory docs/api/inlinesnapshottesting generate-documentation --target InlineSnapshotTesting --output-path docs/api/inlinesnapshottesting --transform-for-static-hosting --hosting-base-path swift-snapshot-testing/api/inlinesnapshottesting
	swift package --allow-writing-to-directory docs/api/customdump generate-documentation --target CustomDump --output-path docs/api/customdump --transform-for-static-hosting --hosting-base-path swift-snapshot-testing/api/customdump

site-build:

	rm -rf docs
	$(MAKE) website-build
	$(MAKE) documentation-build

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:6.3 \
		bash -c 'swift test'

test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme swift-snapshot-testing-Package \
		-destination platform="macOS" | mint run --no-install cpisciotta/xcbeautify -q

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme swift-snapshot-testing-Package \
		-destination platform="iOS Simulator,name=iPhone 17 Pro,OS=26.5" | mint run --no-install cpisciotta/xcbeautify -q

test-swift:
	set -o pipefail && \
	swift test | mint run --no-install cpisciotta/xcbeautify -q

test-tvos:
	set -o pipefail && \
	xcodebuild test \
		-scheme swift-snapshot-testing-Package \
		-destination platform="tvOS Simulator,name=Apple TV 4K (3rd generation),OS=26.5" | mint run --no-install cpisciotta/xcbeautify -q

test-watchos:
	set -o pipefail && \
	xcodebuild test \
		-scheme swift-snapshot-testing-Package \
		-destination platform="watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5" | mint run --no-install cpisciotta/xcbeautify -q

test-all: test-swift test-macos test-ios test-tvos test-watchos test-linux
