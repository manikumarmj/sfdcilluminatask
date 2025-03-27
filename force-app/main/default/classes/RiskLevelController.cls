public class RiskLevelController {

    public static void handleRiskLevelUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        List<Account> accountsToProcess = new List<Account>();
        List<RiskNotificationEvent__e> eventsToPublish = new List<RiskNotificationEvent__e>();

        for (Account acc : newAccounts) {
            Account oldAcc = oldAccountsMap != null ? oldAccountsMap.get(acc.Id) : null;

            if (acc.Risk__c == 'HIGH') {
                if (oldAcc == null || oldAcc.Risk__c != 'HIGH') {
                    eventsToPublish.add(new RiskNotificationEvent__e(
                        AccountId__c = acc.Id,
                        OwnerId__c = acc.OwnerId
                    ));
                    
                }
            }
        }
        system.debug(eventsToPublish);
        if (!eventsToPublish.isEmpty()) {
            publishRiskEvents(eventsToPublish);
        }
    }
    @TestVisible
    private static void publishRiskEvents(List<RiskNotificationEvent__e> events) {
        try {
            if (!events.isEmpty()) {
                List<database.saveResult> result = EventBus.publish(events);
                system.debug(result);
            }
        } catch (Exception e) {
            System.debug('Error publishing platform events: ' + e.getMessage());
        }
    }
}