/*Geo - stuff to test/stuff it should do

Return JSON
Get correct town
Set correct ward / district
Get localised nearest in-borough
Updates to HTML (mark-up, classes)
Event handlers
*/

test("Check API calls with no params", 6, function(){
	equals(AlphaGeo.readAndParseJSONCookie(), false,"readAndParseJSONCookie");
	equal(AlphaGeo.locationName(), null, "locationName");
	equal(AlphaGeo.councils(), true, "councils");
	equal(AlphaGeo.locationCoords(), true, "locationCoords");
	equal(AlphaGeo.locator_object(), true, "locator_object");
	equal(AlphaGeo.deleteGeoCookie(), true, "deleteGeoCookie");
	
});

test("json check", 3, function() {
	
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