public class  SampleTriggerHelper{

public static List<Sample__c> newList;
 
  public static void validateSample(){
  Set<String> prohibitedCity = new Set<String> {'Banglore','Jaipur' };
      for(Sample__c s:newList){
            if(String.isEmpty(s.City__c))
              {
              s.City__c.addError('Please select the city');
              }  
    
          if(prohibitedCity.contains(s.City__c)) {
                if(s.Date_Of_Birth__c  <  date.newinstance(1995, 1, 1))
                {
                s.Date_Of_Birth__c.addError('Date should be greater than 1/1/1995');
                }            
          }
          
          if(s.isSameAddress__c){
              if(!String.isEmpty(s.CurrentAddress__c))
              {
              s.isSameAddress__c.addError('Dont enter current address if it is same as permanent address');
              }
              else
              {
                  s.CurrentAddress__c  = s.PermanentAddress__c;
      
              }
          }
          else if(String.isEmpty(s.CurrentAddress__c)) 
          {
          s.CurrentAddress__c.addError('Please enter current address');
          } 
      }
    }
}