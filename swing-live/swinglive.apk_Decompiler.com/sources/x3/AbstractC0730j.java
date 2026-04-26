package x3;

import java.util.Collection;

/* JADX INFO: renamed from: x3.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0730j extends AbstractC0729i {
    public static int V(Iterable iterable) {
        J3.i.e(iterable, "<this>");
        if (iterable instanceof Collection) {
            return ((Collection) iterable).size();
        }
        return 10;
    }
}
