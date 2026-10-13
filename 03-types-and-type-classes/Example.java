
public class Example {

    static boolean isStrongPassword(String password) {
        return password.length() > 12;
    }

    static String ratePassword(String password) {
        if (isStrongPassword(password)) {
            return password + " is pretty strong!";
        } else {
            return password + " is horrible.";
        }
    }

    public static void main(String[] args) {
        System.out.println(ratePassword("AsStrongAsItGets"));
        System.out.println(ratePassword("ninja"));
    }
}