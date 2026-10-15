import java.util.List;
import java.util.Collections;

public class Main {

    public static <T> List<T> listify(T x) {
        return Collections.singletonList(x);
    }

    public static void main(String[] args) {
        System.out.println(listify(42));
        System.out.println(listify("hello"));
    }
}
