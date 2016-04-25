@isTest
public class SampleTriggerHelperTest{

    static testMethod void validateSample(){
        
        List<Sample__c> samples = new List<Sample__c>();
             //valid object
        Sample__c s2 = new Sample__c(Name = 'ABC0',City__c = 'Mumbai', isSameAddress__c= true,Date_Of_Birth__c  =  date.newinstance(2000, 1, 1) ,PermanentAddress__c = 'ABC1'); 
   
        //Error permanent address
        Sample__c s1 = new Sample__c(Name = 'ABC1',City__c = 'Mumbai', isSameAddress__c= false,Date_Of_Birth__c  =  date.newinstance(1993, 1, 1),PermanentAddress__c = 'ABC1',CurrentAddress__c  = 'ABC'); 
        // Error isSameAddress
        Sample__c s3 = new Sample__c(Name = 'ABC3',City__c = 'Mumbai', isSameAddress__c= true,Date_Of_Birth__c  =  date.newinstance(1998, 1, 1) ,PermanentAddress__c = 'ABC1'); 
        //Error DateOfBirth  
        Sample__c s4 = new Sample__c(Name = 'ABC4',City__c = 'Jaipur', isSameAddress__c= false,Date_Of_Birth__c  =  date.newinstance(1999, 1, 1) ,CurrentAddress__c  = 'ABC',PermanentAddress__c = 'ABC1'); 
        //City required
         Sample__c s5 = new Sample__c(Name = 'ABC5',City__c = 'Hyderabad', isSameAddress__c= false,Date_Of_Birth__c  =  date.newinstance(1993, 1, 1) ,CurrentAddress__c  = 'ABC',PermanentAddress__c = 'ABC1'); 
      
        samples.add(s1);
         samples.add(s2);
        samples.add(s3);
         samples.add(s4);
         samples.add(s5); 
        test.startTest();

        // Insert the Sample records that cause the trigger to execute.
        insert samples;
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
        
        
        //get inserted record
        List<Sample__c> insertedSamples = [SELECT Name  
                                      FROM Sample__c
                                      WHERE Id IN :samples];
          System.assertEquals( insertedSamples.size(),5);
                                 

    }


}