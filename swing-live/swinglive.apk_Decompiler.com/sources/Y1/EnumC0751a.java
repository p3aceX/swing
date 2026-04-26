package y1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: y1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0751a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0751a f6835a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0751a f6836b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ EnumC0751a[] f6837c;

    static {
        EnumC0751a enumC0751a = new EnumC0751a("G711", 0);
        EnumC0751a enumC0751a2 = new EnumC0751a("AAC", 1);
        f6835a = enumC0751a2;
        EnumC0751a enumC0751a3 = new EnumC0751a("OPUS", 2);
        f6836b = enumC0751a3;
        EnumC0751a[] enumC0751aArr = {enumC0751a, enumC0751a2, enumC0751a3};
        f6837c = enumC0751aArr;
        H0.a.z(enumC0751aArr);
    }

    public static EnumC0751a valueOf(String str) {
        return (EnumC0751a) Enum.valueOf(EnumC0751a.class, str);
    }

    public static EnumC0751a[] values() {
        return (EnumC0751a[]) f6837c.clone();
    }
}
