trigger RiskEventListener on RiskNotificationEvent__e (after insert) {
    RiskEventListenerController.handleRiskEvent(Trigger.New);
}