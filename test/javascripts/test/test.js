AlphaGeo.locate('#global-locator-form', "stuff");

test("Check API calls with no params on AlphaGeo", 7, function(){
	equal(AlphaGeo.readAndParseJSONCookie(), false,"readAndParseJSONCookie");
	equal(AlphaGeo.locationName(), null, "locationName");
	equal(AlphaGeo.councils(), null, "councils");
	equal(AlphaGeo.locationCoords(), false, "locationCoords");
	equal(AlphaGeo.locator_object(), true, "locator_object");
	equal(AlphaGeo.deleteGeoCookie(), true, "deleteGeoCookie");
	equal(AlphaGeo.locate(), true, "locate");
});

test("Check locator plugin API", 1, function(){
	stop()

	$(document).ready(function(){
		start();
	});

	equal(AlphaGeo.locate('#global-locator-form'), true, "locator")
});

test("data", 6, function(){
	AlphaGeo.deleteGeoCookie();
	equals(AlphaGeo.locationName("SE10 8UG"),"Greenwich","Borough returned")
});
