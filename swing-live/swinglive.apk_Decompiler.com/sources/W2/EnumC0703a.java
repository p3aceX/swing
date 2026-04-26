package w2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: w2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0703a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0703a f6710b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ EnumC0703a[] f6711c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6712a;

    static {
        EnumC0703a enumC0703a = new EnumC0703a("NONE", 0, 0);
        f6710b = enumC0703a;
        EnumC0703a[] enumC0703aArr = {enumC0703a, new EnumC0703a("PAIR_KEY", 1, 1), new EnumC0703a("ODD_KEY", 2, 2)};
        f6711c = enumC0703aArr;
        H0.a.z(enumC0703aArr);
    }

    public EnumC0703a(String str, int i4, int i5) {
        this.f6712a = i5;
    }

    public static EnumC0703a valueOf(String str) {
        return (EnumC0703a) Enum.valueOf(EnumC0703a.class, str);
    }

    public static EnumC0703a[] values() {
        return (EnumC0703a[]) f6711c.clone();
    }
}
