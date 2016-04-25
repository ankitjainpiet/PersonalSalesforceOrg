public class AccountHandler {
    public static Account insertNewAccount(String accname){
        Account acc=new Account(name= accname);
        try{
        insert acc;
            return acc;
    	}
        catch(DMlException ex){
            return null;
        }
        
        }
}