package x3;

import java.util.Arrays;
import java.util.List;

/* JADX INFO: renamed from: x3.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0729i extends e1.k {
    public static int S(List list) {
        J3.i.e(list, "<this>");
        return list.size() - 1;
    }

    public static List T(Object... objArr) {
        if (objArr.length <= 0) {
            return p.f6784a;
        }
        List listAsList = Arrays.asList(objArr);
        J3.i.d(listAsList, "asList(...)");
        return listAsList;
    }

    public static void U() {
        throw new ArithmeticException("Index overflow has happened.");
    }
}
