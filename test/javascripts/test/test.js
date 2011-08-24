/*Geo - stuff to test/stuff it should do

Return JSON
Get correct town
Set correct ward / district
Get localised nearest in-borough
Updates to HTML (mark-up, classes)
Event handlers
*/
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
	/*	var actual = $('#global-locator-form').locator ({
          	ignore_location_known_on_page_load: false, 
          	error_area_selector: '#global-locator-error'
      	});


	console.log(actual);*/
	$(document).ready(function(){
		start();
	});
	
	equal(AlphaGeo.locate('#global-locator-form'), true, "locator")

	/*
	remove_existing_location_data
	show_known_location
	show_unknown_location
	open_location_dialog
	load_new_locations
	*/
	
});

test("json call check", 3, function() {

	
});

test("event trigger", 1, function(){
	
	
});

test("html updates", 2, function(){
	
	
});

test("data", 6, function(){
	/*click_link 'Set location'
fill_in 'postcode', :with => "SE10 8UG"
click_button "Go"

assert page.has_content?("Greenwich")*/
	AlphaGeo.deleteGeoCookie();
	equals(AlphaGeo.locationName("SE10 8UG"),"Greenwich","Borough returned")
	
});