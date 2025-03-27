public with sharing class CountryMappingController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCountryMappings() {
        try {
            List<Map<String, String>> countryMappings = new List<Map<String, String>>();
            List<CountryCode_to_Country_Mapping__mdt> countryMetadataRecords = [
                SELECT Id, Label, Country_Name__c 
                FROM CountryCode_to_Country_Mapping__mdt 
                ORDER BY Country_Name__c
            ];
            
            for (CountryCode_to_Country_Mapping__mdt record : countryMetadataRecords) {
                countryMappings.add(new Map<String, String>{
                    'value' => record.Label,
                    'label' => record.Country_Name__c
                });
            }
            return countryMappings;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve country mappings: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static ZipWrapper getZipCodeData(String countryCode, String zipCode) {
        ZipWrapper response = new ZipWrapper();
        try {
            if (String.isBlank(countryCode) || String.isBlank(zipCode)) {
                response.isSuccess = false;
                response.errorMessage = 'Country code and ZIP code are required';
                return response;
            }

            String endpoint = 'callout:zipapi/' + countryCode + '/' + zipCode;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                response = ZipWrapper.parse(res.getBody());
                response.isSuccess = true;
            } else if (res.getStatusCode() == 404) {
                response.isSuccess = false;
                response.errorMessage = 'No data found for ZIP code ' + zipCode + ' in country ' + countryCode;
            } else {
                response.isSuccess = false;
                response.errorMessage = 'API call failed with status ' + res.getStatusCode() + ': ' + res.getStatus();
            }
            return response;
        } catch (Exception e) {
            response.isSuccess = false;
            response.errorMessage = 'Unexpected error in ZIP code lookup: ' + e.getMessage();
            return response;
        }
    }

    @AuraEnabled
    public static Boolean saveNonUSData(String country, String city, String state) {
        try {
            if (String.isBlank(country) || String.isBlank(city)) {
                throw new AuraHandledException('Country and city are required');
            }

            ZIP_data__c zipData = new ZIP_data__c(
                City__c = city,
                Country__c = country,
                state__c = state
            );
            insert zipData;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to save non-US data: ' + e.getMessage());
        }
    }
}