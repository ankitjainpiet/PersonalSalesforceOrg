trigger validateSampleTrigger on Sample__c (before insert,before update) {
    SampleTriggerHelper.newList = Trigger.new;
    SampleTriggerHelper.validateSample();
}