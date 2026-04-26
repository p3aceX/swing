package Q3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class E {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final E f1571a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final E f1572b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final E f1573c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ E[] f1574d;

    static {
        E e = new E("DEFAULT", 0);
        f1571a = e;
        E e4 = new E("LAZY", 1);
        f1572b = e4;
        E e5 = new E("ATOMIC", 2);
        f1573c = e5;
        E[] eArr = {e, e4, e5, new E("UNDISPATCHED", 3)};
        f1574d = eArr;
        H0.a.z(eArr);
    }

    public static E valueOf(String str) {
        return (E) Enum.valueOf(E.class, str);
    }

    public static E[] values() {
        return (E[]) f1574d.clone();
    }
}
