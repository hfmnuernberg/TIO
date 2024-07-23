test:
	@echo "- Running test..."
	flutter test

build-android:
	@echo "- Building Android App Bundle"
	cd android && bundle install
	cd android/fastlane && bundle exec fastlane build

deploy-android:
	@echo "- Building and sending Android Build to public testing..."
	cd android && bundle install
	cd android/fastlane && bundle exec fastlane deploy

# deploy-ios:
#     @echo "- Sending iOS Build to TestFlight..."
#     cd ios/fastlane && bundle exec fastlane deploy

# deploy-web:
#     @echo "- Sending Build to Firebase Hosting..."
#     flutter build web
#     firebase deploy

# deploy: test deploy-android deploy-ios deploy-web
deploy: test deploy-android

# .PHONY: test deploy-android deploy-ios deploy-web
.PHONY: test build-android deploy-android