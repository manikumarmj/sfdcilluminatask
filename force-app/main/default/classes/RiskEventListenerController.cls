public class RiskEventListenerController {

    public static void handleRiskEvent(List<RiskNotificationEvent__e> events) {
        List<Case> casesToInsert = new List<Case>();

        for (RiskNotificationEvent__e event : events) {
            Case newCase = createCaseFromEvent(event.AccountId__c, event.OwnerId__c);
             
            if (newCase != null) {
                casesToInsert.add(newCase);
            }
        }
        
        system.debug(casesToInsert);

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }

    private static Case createCaseFromEvent(Id accountId, Id accountOwnerId) {
       

        Id newOwnerId =  [SELECT Id FROM User WHERE Id != :accountOwnerId LIMIT 1].Id;

        Case newCase = new Case(
            AccountId = accountId,
            Subject = 'High Risk Account',
            Description = 'This account has been flagged as high risk.',
            OwnerId = newOwnerId,
            status= 'New',
            origin = 'Phone'
        );

        return newCase;
    }
}