public class SampleExtension{
     Sample__c sample;
     private ApexPages.StandardController sc;    
    public SampleExtension(ApexPages.StandardController stdcontroller){
    this.sample = (Sample__c)stdcontroller.getRecord();
    this.sc  = stdcontroller;
    
    }
    public String getGreeting(){
        return 'Hello ' + sample.name;
    }

}