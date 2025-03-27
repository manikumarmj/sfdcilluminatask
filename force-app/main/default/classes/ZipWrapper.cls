public with sharing class ZipWrapper {
    @AuraEnabled public Boolean isSuccess = true;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public String postCode;
    @AuraEnabled public String country;
    @AuraEnabled public String countryAbbreviation;
    @AuraEnabled public List<Place> places;

    public class Place {
        @AuraEnabled public String placeName;
        @AuraEnabled public String longitude;
        @AuraEnabled public String state;
        @AuraEnabled public String stateAbbreviation;
        @AuraEnabled public String latitude;
    }

    public static ZipWrapper parse(String jsonData) {
        ZipWrapper parsedWrapper = new ZipWrapper();
        try {
            if (String.isBlank(jsonData)) {
                parsedWrapper.isSuccess = false;
                parsedWrapper.errorMessage = 'Empty response from ZIP code API';
                return parsedWrapper;
            }

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
            parsedWrapper.postCode = (String) jsonMap.get('post code');
            parsedWrapper.country = (String) jsonMap.get('country');
            parsedWrapper.countryAbbreviation = (String) jsonMap.get('country abbreviation');
            
            List<Object> placesList = (List<Object>) jsonMap.get('places');
            if (placesList == null) {
                parsedWrapper.isSuccess = false;
                parsedWrapper.errorMessage = 'No places found in ZIP code response';
                return parsedWrapper;
            }

            parsedWrapper.places = new List<Place>();
            for (Object placeObj : placesList) {
                Map<String, Object> placeMap = (Map<String, Object>) placeObj;
                Place place = new Place();
                place.placeName = (String) placeMap.get('place name');
                place.longitude = (String) placeMap.get('longitude');
                place.latitude = (String) placeMap.get('latitude');
                place.state = (String) placeMap.get('state');
                place.stateAbbreviation = (String) placeMap.get('state abbreviation');
                parsedWrapper.places.add(place);
            }
            parsedWrapper.isSuccess = true;
            return parsedWrapper;
        } catch (Exception e) {
            parsedWrapper.isSuccess = false;
            parsedWrapper.errorMessage = 'Error parsing ZIP code response: ' + e.getMessage();
            return parsedWrapper;
        }
    }
}