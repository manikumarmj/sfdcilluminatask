@isTest
public class CountryMappingControllerTest {

    @isTest
    static void testGetCountryMappingsSuccess() {
        Test.startTest();
        List<Map<String, String>> result = CountryMappingController.getCountryMappings();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.size() >= 0);
    }

    @isTest
    static void testGetZipCodeDataSuccess() {
        String jsonResponse = '{"post code": "07008", "country": "United States", "country abbreviation": "US", "places": [{"place name": "Carteret", "longitude": "-74.2313", "latitude": "40.5823", "state": "New Jersey", "state abbreviation": "NJ"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, jsonResponse));

        Test.startTest();
        ZipWrapper result = CountryMappingController.getZipCodeData('US', '07008');
        Test.stopTest();

        System.assertEquals(true, result.isSuccess);
        System.assertEquals('07008', result.postCode);
        System.assertEquals('United States', result.country);
        System.assertEquals('US', result.countryAbbreviation);
        System.assertEquals(1, result.places.size());
        System.assertEquals('Carteret', result.places[0].placeName);
    }

    @isTest
    static void testSaveNonUSDataSuccess() {
        Test.startTest();
        Boolean result = CountryMappingController.saveNonUSData('Canada', 'Toronto', 'ON');
        Test.stopTest();

        System.assertEquals(true, result);
        List<ZIP_data__c> savedData = [SELECT Country__c, City__c, State__c FROM ZIP_data__c];
        System.assertEquals(1, savedData.size());
        System.assertEquals('Canada', savedData[0].Country__c);
        System.assertEquals('Toronto', savedData[0].City__c);
        System.assertEquals('ON', savedData[0].State__c);
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public MockHttpResponseGenerator(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}