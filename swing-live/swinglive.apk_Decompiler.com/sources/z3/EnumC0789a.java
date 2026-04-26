package z3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: z3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0789a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0789a f6999a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ EnumC0789a[] f7000b;

    static {
        EnumC0789a enumC0789a = new EnumC0789a("COROUTINE_SUSPENDED", 0);
        f6999a = enumC0789a;
        EnumC0789a[] enumC0789aArr = {enumC0789a, new EnumC0789a("UNDECIDED", 1), new EnumC0789a("RESUMED", 2)};
        f7000b = enumC0789aArr;
        H0.a.z(enumC0789aArr);
    }

    public static EnumC0789a valueOf(String str) {
        return (EnumC0789a) Enum.valueOf(EnumC0789a.class, str);
    }

    public static EnumC0789a[] values() {
        return (EnumC0789a[]) f7000b.clone();
    }
}
