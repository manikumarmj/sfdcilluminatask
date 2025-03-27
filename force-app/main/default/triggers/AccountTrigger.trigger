trigger AccountTrigger on Account (after insert,after update) {
    if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)){
       /* Account acc=Trigger.new.get(0);
        if(System.IsBatch() == false && System.isFuture() == false){ 
            OpenCageGeocoderUtil.forwardGeocoding(acc.id);
            OpenCageGeocoderUtil.reverseGeocoding(acc.id);
        }*/
        
        RiskLevelController.handleRiskLevelUpdate(Trigger.new, Trigger.oldMap);

        
    }
}