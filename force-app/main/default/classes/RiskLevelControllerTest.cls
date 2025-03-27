@isTest
public class RiskLevelControllerTest {

    @isTest
    static void testNewHighRiskAccount() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Risk__c = 'HIGH',
            OwnerId = UserInfo.getUserId()
        );
        insert testAccount;

        List<Account> newAccounts = new List<Account>{testAccount};
        Map<Id, Account> oldAccountsMap = null;

        Test.startTest();
        RiskLevelController.handleRiskLevelUpdate(newAccounts, oldAccountsMap);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id AND Risk__c = 'HIGH']);
    }

    @isTest
    static void testRiskLevelChangeToHigh() {
        Account oldAccount = new Account(
            Name = 'Test Account',
            Risk__c = 'LOW',
            OwnerId = UserInfo.getUserId()
        );
        insert oldAccount;

        Account updatedAccount = oldAccount.clone(true);
        updatedAccount.Risk__c = 'HIGH';
        Update updatedAccount;

        List<Account> newAccounts = new List<Account>{updatedAccount};
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>{oldAccount.Id => oldAccount};

        Test.startTest();
        RiskLevelController.handleRiskLevelUpdate(newAccounts, oldAccountsMap);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :updatedAccount.Id AND Risk__c = 'HIGH']);
    }

    @isTest
    static void testRiskLevelNoChangeHigh() {
        Account oldAccount = new Account(
            Name = 'Test Account',
            Risk__c = 'HIGH',
            OwnerId = UserInfo.getUserId()
        );
        insert oldAccount;

        Account updatedAccount = oldAccount.clone(true);
        updatedAccount.Name = 'Updated Test Account';

        List<Account> newAccounts = new List<Account>{updatedAccount};
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>{oldAccount.Id => oldAccount};

        Test.startTest();
        RiskLevelController.handleRiskLevelUpdate(newAccounts, oldAccountsMap);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :updatedAccount.Id AND Risk__c = 'HIGH']);
    }

    @isTest
    static void testNonHighRiskAccount() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Risk__c = 'LOW',
            OwnerId = UserInfo.getUserId()
        );
        insert testAccount;

        List<Account> newAccounts = new List<Account>{testAccount};
        Map<Id, Account> oldAccountsMap = null;

        Test.startTest();
        RiskLevelController.handleRiskLevelUpdate(newAccounts, oldAccountsMap);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id AND Risk__c = 'LOW']);
    }

    @isTest
    static void testPublishRiskEvents() {
        List<RiskNotificationEvent__e> events = new List<RiskNotificationEvent__e>{
            new RiskNotificationEvent__e(
                AccountId__c = '001xxxxxxxxxxxxxxx',
                OwnerId__c = UserInfo.getUserId()
            )
        };

        Test.startTest();
        RiskLevelController.publishRiskEvents(events);
        Test.stopTest();

    }

}