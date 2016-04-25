public class StringArrayTest {
    public static List<String> generateStringArray(Integer n){
           List<String>  liststring=new List<String>();
   
        for(integer i=0;i<n;i++){
            liststring.add('Test ' + i);
        }
        return liststring;
    }
}